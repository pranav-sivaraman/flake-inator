{ ... }:
{
  clan.modules.backups =
    { clanLib, ... }:
    {
      _class = "clan.service";
      manifest.name = "backups";
      manifest.readme = "Restic backup service for backing up client machines to a central server.";

      roles.server = {
        description = "Hosts the restic REST server that stores backups.";
        perInstance =
          { roles, ... }:
          {
            nixosModule =
              {
                pkgs,
                lib,
                config,
                ...
              }:
              let
                clientMachines = lib.attrNames (roles.client.machines or { });
                htpasswdEntries = lib.filter (x: x != null) (
                  map (
                    name:
                    clanLib.getPublicValue {
                      flake = config.clan.core.settings.directory;
                      machine = name;
                      generator = "restic-password";
                      file = "htpasswd-entry";
                      default = null;
                    }
                  ) clientMachines
                );
                htpasswdFile = pkgs.writeText "htpasswd" (lib.concatStringsSep "\n" htpasswdEntries);
              in
              {
                services.restic.server = {
                  enable = true;
                  appendOnly = true;
                  "htpasswd-file" = htpasswdFile;
                };

                networking.firewall.allowedTCPPorts = [ 8000 ];
              };
          };
      };

      roles.client = {
        description = "Backs up data to the restic server.";
        perInstance =
          { ... }:
          {
            nixosModule =
              { pkgs, config, ... }:
              {
                clan.core.vars.generators.restic-password = {
                  files.passphrase = {
                    secret = true;
                    owner = "root";
                    mode = "0400";
                  };
                  files.htpasswd-entry.secret = false;
                  runtimeInputs = [
                    pkgs.coreutils
                    pkgs.xkcdpass
                    pkgs.apacheHttpd
                  ];
                  script = ''
                    xkcdpass -n 6 -d - > $out/passphrase
                    htpasswd -nbB "${config.networking.hostName}" "$(cat $out/passphrase)" > $out/htpasswd-entry
                  '';
                };

                clan.core.vars.generators.restic-rest-env = {
                  files.rest-env = {
                    secret = true;
                    owner = "root";
                    mode = "0400";
                  };
                  dependencies = [ "restic-password" ];
                  runtimeInputs = [ pkgs.coreutils ];
                  script = ''
                    passphrase=$(cat $in/restic-password/passphrase)

                    echo "RESTIC_REST_USERNAME=${config.networking.hostName}" > $out/rest-env
                    echo "RESTIC_REST_PASSWORD=$passphrase" >> $out/rest-env
                    echo "RESTIC_FEATURES=device-id-for-hardlinks" >> $out/rest-env
                  '';
                };

                services.restic.backups = {
                  primarybackup = {
                    initialize = true;
                    passwordFile = config.clan.core.vars.generators.restic-password.files.passphrase.path;
                    environmentFile = config.clan.core.vars.generators.restic-rest-env.files.rest-env.path;
                    repository = "rest:http://192.168.1.2:8000/${config.networking.hostName}";

                    paths = [
                      "/persist/.zfs/snapshot/restic-backup"
                      "/home/.zfs/snapshot/restic-backup"
                    ];

                    exclude = [
                      # User caches
                      "**/.cache"
                      "**/cache"
                      "**/Cache"
                      "**/.local/share/Trash"

                      # Package manager caches
                      "**/node_modules"
                      "**/.npm"
                      "**/.yarn"
                      "**/.pnpm-store"

                      # Build artifacts
                      "**/target" # Rust
                      "**/.cargo/registry"
                      "**/.cargo/git"
                      "**/build"
                      "**/dist"

                      # Browser caches
                      "**/.mozilla/firefox/*/cache2"
                      "**/.config/google-chrome/*/Cache"
                      "**/.config/chromium/*/Cache"

                      # Nix
                      "**/.nix-profile"
                    ];

                    backupPrepareCommand = ''
                      ${pkgs.zfs}/bin/zfs snapshot -r rpool/safe@restic-backup
                    '';

                    backupCleanupCommand = ''
                      ${pkgs.zfs}/bin/zfs destroy -r rpool/safe@restic-backup
                    '';

                    pruneOpts = [
                      "--keep-daily 7"
                      "--keep-weekly 4"
                      "--keep-monthly 6"
                    ];
                  };
                };
              };
          };
      };
    };

  clan.inventory.instances.backups = {
    module.input = "self";
    roles.server.machines.agentn = { };
    roles.client.machines.agentc = { };
  };
}
