{
  flake.modules.nixos.zfs = {
    systemd.services.zfs-mount.enable = false;

    services = {
      zfs = {
        trim.enable = true;
        autoScrub.enable = true;
      };
      sanoid = {
        enable = true;
        interval = "*:0/10";  # Run every 10 minutes
        templates = {
          default = {
            autosnap = true;
            autoprune = true;
            frequently_period = 10;
            frequent = 12;   # Every 10 min, keep for 2 hours
            hourly = 48;     # Every hour, keep for 2 days
            daily = 14;      # Every day, keep for 2 weeks
            weekly = 8;      # Every Sunday, keep for ~2 months
            monthly = 24;    # Every month, keep for 2 years
            yearly = 5;      # Every year, keep for 5 years
          };
        };
        datasets = {
          "rpool/safe".useTemplate = [ "default" ];
        };
      };
    };
  };
}
