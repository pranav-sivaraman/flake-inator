{ inputs, ... }:
{
  clan.inventory.machines = {
    agentn = {
      deploy.targetHost = "psivaram@agentn";
    };
  };
  clan.machines.agentn = {
    networking.primaryIp = "192.168.1.2";
    nixpkgs.hostPlatform = "x86_64-linux";
    imports = with inputs.self.aspects; [
      agentn.nixos
      boot.nixos
      firewall.nixos
      home-manager.nixos
      impermanence.nixos
      locale.nixos
      monitoring.nixos
      networkd.nixos
      nix.nixos
      vpn.nixos
      psivaram.nixos
      security.nixos
      ssh.nixos
      users.nixos
      zfs.nixos
    ];
  };
}
