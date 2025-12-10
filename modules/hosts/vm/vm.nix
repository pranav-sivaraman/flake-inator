{ inputs, ... }:
{
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = with inputs.self.modules.nixos; [
      vm
      boot
      impermanence
      locale
      networking
      nix
      psivaram
      secrets
      security
      ssh
      zfs
    ];
  };
}
