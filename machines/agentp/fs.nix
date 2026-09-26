{
  flake.modules.nixos.agentp = {
    disko.devices = {
      disk = {
        root = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_with_Heatsink_4TB_S7DSNJ0Y204067M";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "nofail" ];
                };
              };
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "rpool";
                };
              };
            };
          };
        };
      };
    };
  };
}
