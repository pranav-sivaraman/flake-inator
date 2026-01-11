{ inputs, ... }:
{
  clan.inventory.machines = {
    agenty = {
      deploy.targetHost = "psivaram@192.168.4.3";
    };
  };
  clan.machines.agenty = {
    nixpkgs.hostPlatform = "aarch64-linux";
    imports = with inputs.self.modules.nixos; [
      agenty
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
      zfs
    ];
  };

}
