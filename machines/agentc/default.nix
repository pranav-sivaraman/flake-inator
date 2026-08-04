{ inputs, ... }:
{
  clan.inventory.machines = {
    agentc = {
      deploy.targetHost = "root@agentc"; # TODO: define this somewhere to easily reference?
    };
  };
  clan.machines.agentc = {
    networking.primaryIp = "192.168.1.3";
    networking.headscaleIp = "100.64.0.1";
    nixpkgs.hostPlatform = "x86_64-linux";
    imports =
      (with inputs.self.aspects; [
        agentc.nixos
        defaults.nixos
        boot.nixos
        firewall.nixos
        impermanence.nixos
        monitoring.nixos
        networkd.nixos
        nix.nixos
        zfs.nixos
      ])
      ++ [
        inputs.self.modules.nixos.default
        inputs.self.modules.nixos.psivaram
        inputs.self.modules.nixos.vpn
      ];
  };
}
