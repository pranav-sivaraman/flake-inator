{ inputs, ... }:
{
  clan.inventory.machines = {
    agentc = {
      deploy.targetHost = "psivaram@agentc"; # TODO: define this somewhere to easily reference?
    };
  };
  clan.machines.agentc = {
    nixpkgs.hostPlatform = "x86_64-linux";
    imports = with inputs.self.modules.nixos; [
      agentc
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
