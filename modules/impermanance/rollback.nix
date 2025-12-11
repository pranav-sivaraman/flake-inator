{
  flake.modules.nixos.impermanence =
    { pkgs, ... }:
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
