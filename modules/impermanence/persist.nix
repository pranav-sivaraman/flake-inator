{ inputs, ... }:
{
  flake.aspects.impermanence = {
    nixos =
      { lib, config, ... }:
      {
        imports = [ inputs.impermanence.nixosModules.impermanence ];
        environment.persistence."/persist" = {
          enable = true;
          hideMounts = true;
          directories = [
            "/var/lib/nixos"
            "/var/log/systemd"
            "/var/log/journal"
            "/var/log/lastlog"
            {
              # TODO: make this a virtual or something
              directory = "/var/lib/postgresql";
              user = "postgres";
              group = "postgres";
              mode = "0750";
            }
          ];
          files = [
            "/etc/machine-id"
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
            "/etc/ssh/ssh_host_rsa_key"
            "/etc/ssh/ssh_host_rsa_key.pub"
            "/etc/zfs/zpool.cache"
          ];
        };

        # Recursively fix ownership of any persisted directory that has a non-root owner.
        # Impermanence only chowns the top-level dir, not its contents, so subdirs can
        # accumulate wrong ownership after UID reshuffling. 'Z' = recursive relabel.
        systemd.tmpfiles.rules = lib.concatMap (
          dir: lib.optional (dir.user != "root") "Z ${dir.dirPath} - ${dir.user} ${dir.group} - -"
        ) (lib.concatMap (p: p.directories) (lib.attrValues config.environment.persistence));

        # Make all impermanence-generated mount units wait for userborn to create users/groups
        systemd.services = lib.mkIf config.services.userborn.enable {
          userborn = {
            before = [ "local-fs.target" ];
            wantedBy = [ "local-fs.target" ];
          };
        };
      };
  };
}
