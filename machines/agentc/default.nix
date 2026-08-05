{ inputs, ... }:
{
  clan.inventory.machines = {
    agentc = {
      deploy.targetHost = "root@agentc"; # TODO: define this somewhere to easily reference?
    };
  };
  clan.machines.agentc = {
    nixpkgs.hostPlatform = "x86_64-linux";
    imports =
      (with inputs.self.aspects; [
        agentc.nixos
        boot.nixos
      ])
      ++ [
        inputs.self.modules.nixos.default
        inputs.self.modules.nixos.psivaram
        inputs.self.modules.nixos.vpn
      ];
  };
}
