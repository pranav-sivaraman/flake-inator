{ inputs, ... }:
{
  clan.inventory.machines = {
    agentn = {
      deploy.targetHost = "root@agentn";
    };
  };
  clan.machines.agentn = {
    nixpkgs.hostPlatform = "x86_64-linux";
    imports =
      (with inputs.self.aspects; [
        agentn.nixos
        boot.nixos
      ])
      ++ [
        inputs.self.modules.nixos.default
        inputs.self.modules.nixos.psivaram
        inputs.self.modules.nixos.vpn
      ];
  };
}
