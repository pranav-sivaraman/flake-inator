{
  flake.modules.nixos.agentn = {
    disko.devices = {
      disk = {
        boot = {
          type = "disk";
          device = "/dev/vdb";
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
          device = "/dev/vdc";
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
          device = "/dev/vdd";
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
          device = "/dev/vde";
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
