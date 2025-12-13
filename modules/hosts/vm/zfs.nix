{ inputs, ... }:
{
  flake.modules.nixos.vm =
    { pkgs, ... }:
    {
      imports = [ inputs.disko.nixosModules.disko ];
      disko.devices = {
        disk = {
          root = {
            type = "disk";
            device = "/dev/vda";
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
