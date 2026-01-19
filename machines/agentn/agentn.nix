{ inputs, ... }:
{
  clan.inventory.machines = {
    agentn = {
      deploy.targetHost = "psivaram@192.168.1.2"; # TODO: define this somewhere to easily reference?
    };
  };
  clan.machines.agentn = {
    nixpkgs.hostPlatform = "x86_64-linux";
    imports = with inputs.self.modules.nixos; [
      agentn
      boot
      impermanence
      locale
      firewall
      monitoring
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
