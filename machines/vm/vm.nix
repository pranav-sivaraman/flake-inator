{ inputs, ... }:
{
  clan.inventory.machines = {
    vm = {
      deploy.targetHost = "psivaram@192.168.64.2";
    };
  };
  clan.machines.vm = {
    nixpkgs.hostPlatform = "aarch64-linux";

    imports = with inputs.self.modules.nixos; [
      vm
      boot
      impermanence
      locale
      firewall
      networkd
      nix
      psivaram
      remote-unlock
      security
      ssh
      users
      zfs
    ];
  };
}
