{ ... }:
{
  flake.modules.nixos.monitoring =
    { lib, config, ... }:
    {
      services.smartd = {
        enable = true;
        autodetect = false;
        devices = lib.mapAttrsToList (name: disk: {
          device = disk.device;
        }) (config.disko.devices.disk or { });
      };
    };
}
