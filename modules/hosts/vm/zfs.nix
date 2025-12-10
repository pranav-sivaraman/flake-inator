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
        zpool = {
          rpool = {
            type = "zpool";
            options = {
              ashift = "12";
              autotrim = "on";
            };
            rootFsOptions = {
              acltype = "posixacl";
              compression = "zstd";
              mountpoint = "none";
              xattr = "sa";
            };

            datasets = {
              local = {
                type = "zfs_fs";
                options.mountpoint = "none";
              };
              safe = {
                type = "zfs_fs";
                options = {
                  mountpoint = "none";
                  "com.sun:auto-snapshot" = "true";
                };
              };

              "local/root" = {
                type = "zfs_fs";
                options.mountpoint = "/";
                mountpoint = "/";
                postCreateHook = "zfs list -t snapshot rpool/local/root@blank > /dev/null 2>&1 || zfs snapshot rpool/local/root@blank";
              };
              "local/nix" = {
                type = "zfs_fs";
                options.mountpoint = "/nix";
                mountpoint = "/nix";
              };
              "safe/persist" = {
                type = "zfs_fs";
                options.mountpoint = "/persist";
                mountpoint = "/persist";
              };
              "safe/home" = {
                type = "zfs_fs";
                options.mountpoint = "/home";
                mountpoint = "/home";
              };
            };
          };
        };
      };

      boot.initrd.systemd.services.rollback = {
        description = "Rollback ZFS datasets to a pristine state";
        wantedBy = [
          "initrd.target"
        ];
        after = [
          "zfs-import-rpool.service"
        ];
        before = [
          "sysroot.mount"
        ];
        path = with pkgs; [
          zfs
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          zfs rollback -r rpool/local/root@blank && echo "rollback complete"
        '';
      };
    };
}
