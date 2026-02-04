{

  clan.inventory.instances.localBackup = {
    module.input = "self";
    module.name = "backups";
    roles.server.machines.agentn = { };
    roles.client.machines.agentc = {
      settings.repositoryUrl = "rest:http://192.168.1.2:8000";
    };
  };

  clan.inventory.instances.storj = {
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

      roles = {
        server = {
          perInstance =
            {
              instanceName,
              roles,
              machine,
              ...
            }:
            {
              nixosModule =
                { config, pkgs, ... }:
                let
                  clientMachines = lib.attrNames (roles.client.machines or { });
                in
                {
                  clan.core.vars.generators = lib.listToAttrs (
                    map (clientName: {
                      name = "restic-password-${instanceName}-${clientName}";
                      value = {
                        share = true;
                        files.passphrase = {
                          secret = true;
                          owner = "restic";
                          mode = "0400";
                        };
                      };
                    }) clientMachines
                  );

                  systemd.services = {
                    "create-${instanceName}-htpassword-file" = {
                      description = "Create Restic server's .htpasswd file";
                      before = [ "restic-rest-server.service" ];
                      requiredBy = [ "restic-rest-server.service" ];
                      serviceConfig = {
                        Type = "oneshot";
                        RemainAfterExit = true;
                        User = "restic";
                      };
                      script =
                        let
                          htpasswdFile = "${config.services.restic.server.dataDir}/.htpasswd";
                          addClientCommand = clientName: ''
                            ${pkgs.apacheHttpd}/bin/htpasswd -nbB ${clientName} $(cat ${
                              config.clan.core.vars.generators."restic-password-${instanceName}-${clientName}".files.passphrase.path
                            }) >> ${htpasswdFile}
                          '';
                        in
                        ''
                          ${pkgs.coreutils}/bin/rm -f ${htpasswdFile}
                          ${lib.concatMapStringsSep "\n" addClientCommand clientMachines}
                        '';
                    };
                  };

                  services.restic.server = {
                    enable = true;
                    appendOnly = true;
                    # prometheus = true; # TODO
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
        client = {
          interface = {
            options.repositoryUrl = lib.mkOption {
              type = lib.types.str;
              description = "Restic repository base URL. Hostname will be appended automatically.";
              example = "rest:http://192.168.1.2:8000 or s3:https://gateway.storjshare.io/bucket-name";
            };
          };
          perInstance =
            {
              instanceName,
              settings,
              machine,
              ...
            }:
            {
              nixosModule =
                { config, pkgs, ... }:
                let
                  passphraseSecret = "restic-password-${instanceName}-${machine.name}";
                  s3Secret = "restic-s3-${instanceName}";
                  hasS3 = lib.hasPrefix "s3:" settings.repositoryUrl;
                in
                {
                  clan.core.vars.generators = lib.mkMerge [
                    {
                      # TODO: rotate keys service
                      "${passphraseSecret}" = {
                        share = !hasS3;
                        files.passphrase = {
                          secret = true;
                          owner = "restic";
                          mode = "0400";
                        };
                        runtimeInputs = [
                          pkgs.coreutils
                          pkgs.xkcdpass
                        ];
                        script = ''
                          xkcdpass -n 6 -d - > $out/passphrase
                        '';
                      };
                    }
                    (lib.mkIf (hasS3) {
                      "${s3Secret}" = {
                        # TODO: should this be share?
                        prompts.access-key = {
                          description = "S3 Access Key ID for ${instanceName}";
                          type = "hidden";
                          persist = false;
                        };
                        prompts.secret-key = {
                          description = "S3 Secret Access Key for ${instanceName}";
                          type = "hidden";
                          persist = false;
                        };
                        files.credentials = {
                          secret = true;
                          owner = "restic";
                          mode = "0400";
                        };
                        runtimeInputs = [ pkgs.coreutils ];
                        script = ''
                          access_key=$(cat $prompts/access-key)
                          secret_key=$(cat $prompts/secret-key)

                          cat > $out/credentials <<EOF
                          [default]
                          aws_access_key_id=$access_key
                          aws_secret_access_key=$secret_key
                          EOF
                        '';
                      };
                    })
                  ];

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

                  services.restic.backups =
                    let
                      passwordFile = config.clan.core.vars.generators.${passphraseSecret}.files.passphrase.path;
                      environmentFile = pkgs.writeText "restic-env" ''
                        RESTIC_FEATURES=device-id-for-hardlinks
                        ${
                          if hasS3 then
                            ''
                              AWS_SHARED_CREDENTIALS_FILE=${config.clan.core.vars.generators.${s3Secret}.files.credentials.path}
                            ''
                          else
                            ''
                              RESTIC_REST_USERNAME=${machine.name}
                            ''
                        }
                      '';
                    in
                    {
                      "primarybackup-${instanceName}" = {
                        initialize = true;
                        user = "restic";
                        package = pkgs.writeShellScriptBin "restic" ''
                          exec /run/wrappers/bin/restic "$@"
                        '';
                        extraOptions = [
                          "--verbose"
                        ];
                        repository = "${settings.repositoryUrl}/${machine.name}";
                        passwordFile = passwordFile;
                        environmentFile = toString environmentFile;
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

                  services.postgresqlBackup.enable = lib.mkIf config.services.postgresql.enable true;
                  environment.persistence."/persist".directories = lib.mkIf config.services.postgresql.enable [
                    "${config.services.postgresqlBackup.location}"
                  ];
                };
            };
        };
      };
    };
}
