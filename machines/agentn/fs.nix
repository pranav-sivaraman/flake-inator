{
  flake.modules.nixos.agentn = {
    disko.devices = {
      disk = {
        boot = {
          type = "disk";
          device = "/dev/disk/by-id/mmc-DV4064_0x03086a32";
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
            };
          };
        };
        data1 = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-Samsung_SSD_990_EVO_Plus_4TB_S7U8NJ0Y405006Z";
          content = {
            type = "gpt";
            partitions = {
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
        data2 = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-Samsung_SSD_990_EVO_Plus_4TB_S7U8NJ0Y514985X";
          content = {
            type = "gpt";
            partitions = {
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
        data3 = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-WD_BLACK_SN7100_4TB_25203H800223";
          content = {
            type = "gpt";
            partitions = {
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
      zpool.rpool = {
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "raidz1";
                members = [
                  "data1"
                  "data2"
                  "data3"
                ];
              }
            ];
          };
        };
      };
    };
  };
}
