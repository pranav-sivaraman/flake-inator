{ inputs, ... }:
{
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = with inputs.self.modules.nixos; [
      # Hardware detection via nixos-facter
      inputs.nixos-facter-modules.nixosModules.facter
      { config.facter.reportPath = ./facter.json; }

      {
        system.stateVersion = "25.11";

        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        nixpkgs.config.allowUnfree = true;

        networking = {
          hostName = "vm";
          hostId = "f204fc66";
        };

        boot = {
          loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };
          zfs = {
            forceImportRoot = false;
          };
        };
      }

      # Disk management
      inputs.disko.nixosModules.disko

      # Shared modules
      psivaram
      ssh
      zfs
    ];
  };
}
