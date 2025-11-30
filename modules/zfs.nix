{
  flake.modules.nixos.zfs = {
    services.zfs = {
      trim.enable = true;
      autoScrub.enable = true;
      autoSnapshot.enable = true;
    };
  };
}
