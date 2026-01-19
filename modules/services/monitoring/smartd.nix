{ ... }:
{
  flake.modules.nixos.monitoring =
    { lib, config, ... }:
    let
      hasZfsPartition = disk:
        lib.any (partition: (partition.content.type or "") == "zfs")
          (lib.attrValues (disk.content.partitions or { }));
    in
    {
      services.smartd = {
        enable = true;
        autodetect = false;
        devices = lib.mapAttrsToList (name: disk: {
          device = disk.device;
        }) (lib.filterAttrs (_: hasZfsPartition) (config.disko.devices.disk or { }));
      };
    };
}
