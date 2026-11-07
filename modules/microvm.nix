{ inputs, ... }:
{
  flake-file.inputs.microvm = {
    url = "github:microvm-nix/microvm.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Minimal guest base shared by all MicroVMs. It deliberately does not import
  # `nixos.default`: sops, clan secrets, disko, zfs/preservation, monitoring and
  # home-manager all arrive through that module, and every one of them makes the
  # guest closure bigger and slower to build.
  flake.modules.nixos.microvm-guest =
    { config, lib, ... }:
    {
      imports = [
        inputs.microvm.nixosModules.microvm
        inputs.self.modules.generic.constants
      ];

      system.stateVersion = lib.mkDefault "25.05";

      networking.firewall.allowedTCPPorts = [ 22 ];

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "prohibit-password";
        };
      };

      users.users.root.openssh.authorizedKeys.keys = config.userData.psivaram.sshKeys;
      users.users.psivaram = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = config.userData.psivaram.sshKeys;
      };

      # Required for `nixos-rebuild --target-host ... --use-remote-sudo`; there is
      # no console password to type either way.
      security.sudo.wheelNeedsPassword = false;

      # `nix run .#microvm-dev` drops straight into the guest console.
      services.getty.autologinUser = "root";

      microvm = {
        vcpu = lib.mkDefault 4;
        mem = lib.mkDefault 4096;

        # Share the host's /nix/store instead of packing a squashfs/erofs image.
        # `storeOnDisk` defaults to `!any (share with source == "/nix/store")`,
        # so this single share is what makes rebuilds incremental and is also
        # what disables the image build.
        shares = [
          {
            tag = "ro-store";
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            readOnly = true;
          }
        ];

        # User-mode networking is outbound-only; host -> guest needs forwardPorts.
        interfaces = [
          {
            type = "user";
            id = "vm0";
            mac = "02:00:00:00:00:01";
          }
        ];
        forwardPorts = [
          {
            host.port = 2222;
            guest.port = 22;
          }
        ];

        # The guest's root filesystem is tmpfs, so without this /var (ssh host
        # keys, machine-id, userborn state) is lost on every restart.
        volumes = [
          {
            mountPoint = "/var";
            image = "var.img";
            size = 4096;
          }
        ];

        # No interactive qemu monitor: stdin is not a tty when the runner is
        # started unattended (launchd supplies /dev/null).
        qemu.extraArgs = [ "-monitor" "none" ];
      };
    };
}
