{
  flake.modules.nixos.impermanence =
    { config, ... }:
    {
      # TODO: may need to setup some guard/type checking for rpool?
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
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          ${config.boot.zfs.package}/bin/zfs rollback -r rpool/local/root@blank
          echo "Rollback complete!"
        '';
      };
    };
}
