{ inputs, ... }:
{
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = with inputs.self.modules.nixos; [
      # Hardware detection via nixos-facter
      inputs.nixos-facter-modules.nixosModules.facter
      { config.facter.reportPath = ./facter.json; }

      vm

      # Shared modules
      defaultinator
      psivaram
      ssh
      zfs
    ];
  };
}
