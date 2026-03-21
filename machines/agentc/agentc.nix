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
