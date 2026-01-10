{
  flake.modules.nixos.zfs = {
    systemd.services.zfs-mount.enable = false;

    boot.zfs.devNodes = "/dev/disk/by-partuuid";

    services.zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };
  };
}
