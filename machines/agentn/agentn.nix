{ inputs, ... }:
{
  clan.inventory.machines = {
    agentn = {
      deploy.targetHost = "psivaram@agentn";
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
      inputs.self.aspects.nix.nixos
      inputs.self.aspects.zfs.nixos
      psivaram
      remote-unlock
      security
      ssh
      users
    ];
  };

}
