{
  flake.modules.nixos.zfs = {
    services.zfs = {
      trim.enable = true;
      autoScrub.enable = true;

      autoSnapshot = {
        enable = true;
        frequent = 4;
        hourly = 24;
        daily = 7;
        weekly = 4;
        monthly = 12;
      };
    };
  };
}
