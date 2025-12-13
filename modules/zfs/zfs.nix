{
  flake.modules.nixos.zfs = {
    systemd.services.zfs-mount.enable = false;

    services.zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };
  };
}
