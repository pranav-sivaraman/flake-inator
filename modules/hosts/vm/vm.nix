{ inputs, ... }:
{
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = with inputs.self.modules.nixos; [
      vm
      defaultinator
      psivaram
      ssh
      zfs
    ];
  };
}
