{
  flake.modules.nixos.zfs = {
    disko.devices.zpool.rpool = {
      type = "zpool";
      options = {
        ashift = "12";
        autotrim = "on";
      };
      rootFsOptions = {
        acltype = "posixacl";
        compression = "zstd";
        encryption = "aes-256-gcm";
        keyformat = "passphrase";
        keylocation = "prompt";
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
          mountpoint = "/";
          postCreateHook = "zfs list -t snapshot rpool/local/root@blank > /dev/null 2>&1 || zfs snapshot rpool/local/root@blank";
        };
        "local/nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
        };
        "safe/persist" = {
          type = "zfs_fs";
          mountpoint = "/persist";
        };
        "safe/home" = {
          type = "zfs_fs";
          mountpoint = "/home";
        };
      };
    };

    fileSystems."/persist".neededForBoot = true;
  };
}
