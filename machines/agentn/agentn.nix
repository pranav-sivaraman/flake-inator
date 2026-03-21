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
      impermanence
      locale
      firewall
      monitoring
      networkd
      psivaram
      security
      ssh
      users
      inputs.self.aspects.boot.nixos
      inputs.self.aspects.nix.nixos
      inputs.self.aspects.zfs.nixos
    ];
  };

}
