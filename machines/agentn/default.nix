{ inputs, ... }:
{
  clan.inventory.machines = {
    agentn = {
      deploy.targetHost = "root@agentn";
    };
  };
  clan.machines.agentn = {
    networking.primaryIp = "192.168.1.2";
    networking.headscaleIp = "100.64.0.2";
    nixpkgs.hostPlatform = "x86_64-linux";
    imports = with inputs.self.aspects; [
      agentn.nixos
      defaults.nixos
      boot.nixos
      firewall.nixos
      home-manager.nixos
      impermanence.nixos
      monitoring.nixos
      networkd.nixos
      nix.nixos
      vpn.nixos
      psivaram.nixos
      ssh.nixos
      users.nixos
      zfs.nixos
    ];
  };
}
