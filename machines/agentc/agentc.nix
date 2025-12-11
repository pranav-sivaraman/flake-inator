{ inputs, ... }:
{
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
