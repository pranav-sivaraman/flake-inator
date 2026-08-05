{
  flake.modules.nixos.agentc = {
    disko.devices = {
      disk = {
        root = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_253564800204";
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
