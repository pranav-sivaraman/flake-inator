{ inputs, ... }:
{
  clan.inventory.machines = {
    agentc = {
      deploy.targetHost = "root@agentc"; # TODO: define this somewhere to easily reference?
    };
  };
  clan.machines.agentc = {
    nixpkgs.hostPlatform = "x86_64-linux";
    imports = with inputs.self.modules.nixos; [
      default
      agentc
      psivaram
      vpn
    ];
  };
}
