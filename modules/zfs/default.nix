{
  imports = [
    ./rpool.nix
    ./snapshots.nix
  ];

  flake.aspects.zfs = {
    nixos =
      { lib, pkgs, ... }:
      {
        systemd.services.zfs-mount.enable = false;

        boot.zfs.devNodes = "/dev/disk/by-partuuid";

        boot.zfs.package = pkgs.zfs_unstable;

        services.zfs = {
          trim.enable = true;
          autoScrub.enable = true;
          autoSnapshot.enable = lib.mkForce false;
        };
      };
  };
}
