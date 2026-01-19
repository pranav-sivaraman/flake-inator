{ inputs, ... }:
{
  clan.inventory.machines = {
    agentc = {
      deploy.targetHost = "psivaram@192.168.1.3"; # TODO: define this somewhere to easily reference?
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
      nix
      psivaram
      remote-unlock
      security
      ssh
      users
      zfs
    ];
  };

}
