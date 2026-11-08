{ inputs, ... }:
{
  flake-file.inputs.microvm = {
    url = "github:microvm-nix/microvm.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Minimal guest base shared by all MicroVMs. It deliberately does not import
  # `nixos.default`: sops, clan secrets, disko, zfs/preservation and monitoring
  # all arrive through that module, and every one of them makes the guest closure
  # bigger and slower to build. home-manager is wired up by hand below instead.
  flake.modules.nixos.microvm-guest =
    { config, lib, ... }:
    {
      imports = [
        inputs.microvm.nixosModules.microvm
        inputs.home-manager.nixosModules.home-manager
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

        # /etc lives on the tmpfs root, so keys generated there change on every
        # boot. /var is persistent.
        hostKeys = [
          {
            type = "rsa";
            bits = 4096;
            path = "/var/lib/ssh/ssh_host_rsa_key";
          }
          {
            type = "ed25519";
            path = "/var/lib/ssh/ssh_host_ed25519_key";
          }
        ];
      };

      users.users.root.openssh.authorizedKeys.keys = config.userData.psivaram.sshKeys;
      users.users.psivaram = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = config.userData.psivaram.sshKeys;
      };

      home-manager = {
        backupFileExtension = "backup";
        users.psivaram.imports = [ inputs.self.modules.homeManager.default ];
      };

      # For unattended `nixos-rebuild --target-host ... --use-remote-sudo`.
      security.sudo.wheelNeedsPassword = false;

      # `nix run .#microvm-dev` drops straight into the guest console.
      services.getty.autologinUser = "root";

      # Unlike /var, /home is not mounted before stage-2 activation, so
      # `update-users-groups.pl` would create /home/psivaram on the tmpfs root
      # and the volume would then be mounted over it.
      fileSystems."/home".neededForBoot = true;

      microvm = {
        vcpu = lib.mkDefault 4;
        mem = lib.mkDefault 4096;

        # Share the host's /nix/store so rebuilds stay incremental and no store
        # image has to be built.
        shares = [
          {
            tag = "ro-store";
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            readOnly = true;
          }
        ];

        # A writable store overlay keeps nix working in the guest: microvm.nix
        # enables nix-daemon only when this is set, and home-manager's activation
        # needs it.
        writableStoreOverlay = "/nix/.rw-store";

        # The guest's root filesystem is tmpfs, so state needs real filesystems
        # to survive a restart.
        volumes = [
          {
            mountPoint = "/var";
            image = "var.img";
            size = 4096;
          }
          {
            mountPoint = "/home";
            image = "home.img";
            size = 8192;
          }
          {
            mountPoint = "/nix/.rw-store";
            image = "rw-store.img";
            size = 8192;
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
            # Bind loopback only: qemu's hostfwd listens on every interface when
            # host.address is left empty, which exposes the guest's sshd to
            # whatever network the laptop happens to be on.
            host.address = "127.0.0.1";
            host.port = 2222;
            guest.port = 22;
          }
        ];
      };
    };
}
