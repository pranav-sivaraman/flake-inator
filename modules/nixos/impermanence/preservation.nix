{ inputs, ... }:
{
  flake.aspects.impermanence = {
    nixos = _: {
      imports = [ inputs.impermanence.nixosModules.preservation ];
      preservation = {
        enable = true;
        preserveAt."/persist" = {
          commonMountOptions = [
            "x-gvfs-hide"
            "x-gdu.hide"
          ];
          directories = [
            "/etc/secureboot"
            "/var/lib/bluetooth"
            "/var/lib/fprint"
            "/var/lib/fwupd"
            "/var/lib/libvirt"
            "/var/lib/power-profiles-daemon"
            "/var/lib/systemd/coredump"
            "/var/lib/systemd/rfkill"
            "/var/lib/systemd/timers"
            "/var/log"
            {
              directory = "/var/lib/nixos";
              inInitrd = true;
            }
            {
              directory = "/var/lib/postgresql";
              user = "postgres";
              group = "postgres";
              mode = "0750";
            }
          ];

          files = [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
            {
              file = "/etc/ssh/ssh_host_rsa_key";
              how = "symlink";
              configureParent = true;
            }
            "/etc/ssh/ssh_host_rsa_key.pub"
            {
              file = "/etc/ssh/ssh_host_ed25519_key";
              how = "symlink";
              configureParent = true;
            }
            "/etc/ssh/ssh_host_ed25519_key.pub"
            "/var/lib/usbguard/rules.conf"
            "/etc/zfs/zpool.cache"

            # creates a symlink on the volatile root
            # creates an empty directory on the persistent volume, i.e. /persist/var/lib/systemd
            # does not create an empty file at the symlink's target (would require `createLinkTarget = true`)
            {
              file = "/var/lib/systemd/random-seed";
              how = "symlink";
              inInitrd = true;
              configureParent = true;
            }
          ];
        };
      };

      # /etc/machine-id is already persistent, so there is no transient ID to commit.
      systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
    };
  };
}
