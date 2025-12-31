{ inputs, ... }:
{
  clan.machines.agentc = {
    nixpkgs.hostPlatform = "x86_64-linux";
    imports = with inputs.self.modules.nixos; [
      boot
      impermanence
      locale
      firewall
      networkd
      nix
      psivaram
      remote-unlock
      security
      ssh
      zfs
    ];
  };

}
