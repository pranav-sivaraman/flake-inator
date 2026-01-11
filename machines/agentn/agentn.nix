{ inputs, ... }:
{
  clan.inventory.machines = {
    agentn = {
      deploy.targetHost = "psivaram@192.168.4.4";
    };
  };
  clan.machines.agentn = {
    nixpkgs.hostPlatform = "aarch64-linux";
    imports = with inputs.self.modules.nixos; [
      agentn
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
