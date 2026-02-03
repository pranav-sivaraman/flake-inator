{ ... }:
{
  clan.inventory.instances.localBackup = {
    module.input = "self";
    module.name = "backups";
    roles.server.machines.agentn = { };
    roles.client.settings.repositoryUrl = "rest:http://192.168.1.2:8000"; # TODO: use exporters
    roles.client.machines.agentc = { };
  };

  clan.inventory.instances.s3Backup = {
    module.input = "self";
    module.name = "backups";
    roles.client.settings.repositoryUrl = "s3:https://gateway.storjshare.io/backup";
    roles.client.machines.agentn = { };
  };

  clan.modules.backups =
    { clanLib, lib, ... }:
    {
      _class = "clan.service";
      manifest.name = "backups";
      manifest.readme = "Restic backup service for backing up client machines to a central server.";

      roles.server = {
        description = "Hosts the restic REST server that stores backups.";
        perInstance =
          { roles, instanceName, ... }:
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
                      generator = "restic-password-${instanceName}";
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

                environment.persistence."/persist".directories = [
                  {
                    directory = "${config.services.restic.server.dataDir}";
                    user = "restic";
                    group = "restic";
                  }
                ];
              };
          };
      };

      roles.client = {
        description = "Backs up data to the restic server.";

        interface = {
          options.repositoryUrl = lib.mkOption {
            type = lib.types.str;
            description = "Restic repository base URL. Hostname will be appended automatically.";
            example = "rest:http://192.168.1.2:8000 or s3:https://gateway.storjshare.io/bucket-name";
          };
        };

        perInstance =
          { instanceName, settings, ... }:
          {
            nixosModule =
              {
                pkgs,
                config,
                lib,
                ...
              }:
              let
                generatorName = suffix: "restic-${suffix}-${instanceName}";
              in
              {
                users = {
                  users.restic = {
                    group = "restic";
                    isSystemUser = true;
                  };
                  groups.restic = { };
                };

                systemd.services.zfs-delegate-restic = {
                  description = "Delegate ZFS permissions for restic backups";
                  after = [ "zfs-import.target" ];
                  wantedBy = [ "multi-user.target" ];
                  serviceConfig = {
                    Type = "oneshot";
                    RemainAfterExit = true;
                  };
                  script = ''
                    ${config.boot.zfs.package}/bin/zfs allow restic snapshot,destroy,mount rpool/safe
                  '';
                };

                security.wrappers.restic = {
                  source = lib.getExe pkgs.restic;
                  owner = "restic";
                  group = "restic";
                  permissions = "500"; # or u=rx,g=,o=
                  capabilities = "cap_dac_read_search+ep";
                };

                clan.core.vars.generators.${generatorName "password"} = {
                  files.passphrase = {
                    secret = true;
                    owner = "restic";
                    mode = "0400";
                  };
                  files.htpasswd-entry = lib.mkIf (lib.hasPrefix "rest:" settings.repositoryUrl) {
                    secret = false;
                  };
                  runtimeInputs = [
                    pkgs.coreutils
                    pkgs.xkcdpass
                  ]
                  ++ lib.optional (lib.hasPrefix "rest:" settings.repositoryUrl) pkgs.apacheHttpd;
                  script = ''
                    xkcdpass -n 6 -d - > $out/passphrase
                  ''
                  + lib.optionalString (lib.hasPrefix "rest:" settings.repositoryUrl) ''
                    htpasswd -nbB "${config.networking.hostName}" "$(cat $out/passphrase)" > $out/htpasswd-entry
                  '';
                };

                clan.core.vars.generators.${generatorName "env"} = lib.mkMerge [
                  (lib.mkIf (lib.hasPrefix "rest:" settings.repositoryUrl) {
                    files.env = {
                      secret = true;
                      owner = "restic";
                      mode = "0400";
                    };
                    dependencies = [ (generatorName "password") ];
                    runtimeInputs = [ pkgs.coreutils ];
                    script = ''
                      passphrase=$(cat $in/${generatorName "password"}/passphrase)
                      echo "RESTIC_REST_USERNAME=${config.networking.hostName}" > $out/env
                      echo "RESTIC_REST_PASSWORD=$passphrase" >> $out/env
                      echo "RESTIC_FEATURES=device-id-for-hardlinks" >> $out/env
                    '';
                  })

                  (lib.mkIf (lib.hasPrefix "s3:" settings.repositoryUrl) {
                    files.env = {
                      secret = true;
                      owner = "root";
                      mode = "0400";
                    };
                    prompts.access-key = {
                      description = "S3 Access Key ID for ${instanceName}";
                      type = "hidden";
                    };
                    prompts.secret-key = {
                      description = "S3 Secret Access Key for ${instanceName}";
                      type = "hidden";
                    };
                    runtimeInputs = [ pkgs.coreutils ];
                    script = ''
                      access_key=$(cat $prompts/access-key)
                      secret_key=$(cat $prompts/secret-key)
                      echo "AWS_ACCESS_KEY_ID=$access_key" > $out/env
                      echo "AWS_SECRET_ACCESS_KEY=$secret_key" >> $out/env
                      echo "RESTIC_FEATURES=device-id-for-hardlinks" >> $out/env
                    '';
                  })
                ];

                # TODO: change to specific databases
                services.postgresqlBackup.enable = lib.mkIf config.services.postgresql.enable true;
                environment.persistence."/persist".directories = lib.mkIf config.services.postgresql.enable [
                  "${config.services.postgresqlBackup.location}"
                ];

                services.restic.backups = {
                  primarybackup = {
                    initialize = true;
                    user = "restic";
                    package = pkgs.writeShellScriptBin "restic" ''
                      exec /run/wrappers/bin/restic "$@"
                    '';
                    repository = "${settings.repositoryUrl}/${config.networking.hostName}";
                    passwordFile = config.clan.core.vars.generators.${generatorName "password"}.files.passphrase.path;
                    environmentFile = config.clan.core.vars.generators.${generatorName "env"}.files.env.path;

                    extraOptions = [
                      "--verbose"
                    ];

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
                      if ${config.boot.zfs.package}/bin/zfs list -t snapshot rpool/safe@restic-backup 2>/dev/null; then
                        ${config.boot.zfs.package}/bin/zfs destroy -r rpool/safe@restic-backup
                      fi
                      ${config.boot.zfs.package}/bin/zfs snapshot -r rpool/safe@restic-backup
                    '';

                    backupCleanupCommand = ''
                      ${config.boot.zfs.package}/bin/zfs destroy -r rpool/safe@restic-backup
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
}
