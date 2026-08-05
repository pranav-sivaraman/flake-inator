{ inputs, ... }:
{
  clan.inventory.machines = {
    agentn = {
      deploy.targetHost = "root@agentn";
    };
  };
  clan.machines.agentn = {
    nixpkgs.hostPlatform = "x86_64-linux";
    imports = with inputs.self.modules.nixos; [
      default
      agentn
      psivaram
      vpn
    ];
  };
}
