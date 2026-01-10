{ inputs, ... }:
{
  clan.machines.agentn = {
    nixpkgs.hostPlatform = "aarch64-linux";
    imports = with inputs.self.modules.nixos; [
      agentn
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
