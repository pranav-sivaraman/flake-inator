{ inputs, ... }:
{
  clan.inventory.machines = {
    agentn = {
      deploy.targetHost = "psivaram@agentn";
    };
  };
  clan.machines.agentn = {
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
      psivaram.nixos
      security.nixos
      ssh.nixos
      users.nixos
      zfs.nixos
    ];
  };
}
