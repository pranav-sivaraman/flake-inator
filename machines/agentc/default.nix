{ inputs, ... }:
{
  clan.inventory.machines = {
    agentc = {
      deploy.targetHost = "psivaram@agentc"; # TODO: define this somewhere to easily reference?
    };
  };
  clan.machines.agentc = {
    networking.primaryIp = "192.168.1.3";
    nixpkgs.hostPlatform = "x86_64-linux";
    imports = with inputs.self.aspects; [
      agentc.nixos
      boot.nixos
      firewall.nixos
      home-manager.nixos
      impermanence.nixos
      locale.nixos
      monitoring.nixos
      networkd.nixos
      nix.nixos
      psivaram.nixos
      security.nixos
      ssh.nixos
      users.nixos
      zfs.nixos
    ];
  };
}
