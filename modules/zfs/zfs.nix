{
  flake.modules.nixos.zfs =
    { lib, ... }:
    {
      systemd.services.zfs-mount.enable = false;

      boot.zfs.devNodes = "/dev/disk/by-partuuid";

      services.zfs = {
        trim.enable = true;
        autoScrub.enable = true;
        autoSnapshot.enable = lib.mkForce false;
      };
    };
}
