{
  clan.inventory.instances.samba = {
    module.input = "self";
    module.name = "smb";

    roles.server.machines.agentn = { };
    roles.client.machines.agentc = { };
  };
  clan.modules.smb =
    {
      clanLib,
      exports,
      lib,
      ...
    }:
    {
      _class = "clan.service";
      manifest.name = "smb";
      manifest.readme = "SMB storage over network";

      roles = {
        server = {
          description = "Hosts the SMB/Samba server that provides network storage shares.";
          perInstance =
            {
              instanceName,
              roles,
              machine,
              ...
            }:
            let
              allExports = clanLib.selectExports (_scope: true) exports;
              storageExports = lib.filterAttrs (_scope: data: data ? storage && data.storage != null) allExports;
              storageUsers = lib.unique (lib.mapAttrsToList (_scope: data: data.storage.user) storageExports);

              # Flatten exports - each scope can have multiple directories
              flattenedExports = lib.flatten (
                lib.mapAttrsToList (
                  scope: data:
                  let
                    storage = data.storage;
                    exportsList = storage.exports;
                  in
                  lib.imap0 (idx: export: {
                    inherit scope;
                    inherit (storage) user group readOnly;
                    inherit (export) path mountPoint;
                    # Simple naming: user-0, user-1, etc.
                    shareName = "${storage.user}-${toString idx}";
                  }) exportsList
                ) storageExports
              );

              normalizedGroup = export: if export.group != "" then export.group else export.user;

              storageGroups = lib.unique (storageUsers ++ map normalizedGroup flattenedExports);

              userExtraGroups = lib.listToAttrs (
                map (
                  username:
                  lib.nameValuePair username (
                    lib.unique (
                      lib.filter (group: group != username) (
                        map normalizedGroup (lib.filter (export: export.user == username) flattenedExports)
                      )
                    )
                  )
                ) storageUsers
              );

              shareConfigs = lib.listToAttrs (
                map (
                  export:
                  let
                    group = normalizedGroup export;
                  in
                  lib.nameValuePair export.shareName {
                    path = export.path;
                    "valid users" = "${export.user} @${group}";
                    "write list" = lib.mkIf (!export.readOnly) "${export.user} @${group}";
                    "read only" = if export.readOnly then "yes" else "no";
                    browseable = "yes";
                    "guest ok" = "no";
                    "create mask" = "0664";
                    "directory mask" = "0775";
                    "force create mode" = "0660";
                    "force directory mode" = "0770";
                    "force user" = export.user;
                    "force group" = group;
                  }
                ) flattenedExports
              );
            in
            {
              nixosModule =
                { config, pkgs, ... }:
                {
                  services.samba = {
                    enable = true;
                    openFirewall = true;

                    settings = {
                      global = {
                        "workgroup" = "WORKGROUP";
                        "server string" = "Samba Server - ${machine.name}";
                        "security" = "user";
                        "map to guest" = "never";
                        "dns proxy" = "no";
                        "log file" = "/var/log/samba/%m.log";
                        "max log size" = "50";
                      };
                    }
                    // shareConfigs;
                  };

                  # Create system users and groups for each storage export
                  users.users = lib.listToAttrs (
                    map (username: {
                      name = username;
                      value = {
                        isSystemUser = true;
                        group = username;
                        extraGroups = userExtraGroups.${username} or [ ];
                        description = "SMB user for ${username}";
                      };
                    }) storageUsers
                  );

                  users.groups = lib.listToAttrs (
                    map (group: {
                      name = group;
                      value = { };
                    }) storageGroups
                  );

                  # Persist samba state only
                  preservation.preserveAt."/persist".directories = [
                    {
                      directory = "/var/lib/samba";
                      user = "root";
                      group = "root";
                      mode = "0755";
                    }
                    {
                      directory = "/var/log/samba";
                      user = "root";
                      group = "root";
                      mode = "0755";
                    }
                  ];

                  # Generate SMB passwords for each user
                  clan.core.vars.generators = lib.listToAttrs (
                    map (username: {
                      name = "smb-password-${instanceName}-${username}";
                      value = {
                        share = true; # Share password with clients
                        files.password = {
                          secret = true;
                          owner = "root";
                          mode = "0400";
                        };
                        runtimeInputs = [
                          pkgs.coreutils
                          pkgs.xkcdpass
                        ];
                        script = ''
                          xkcdpass -n 2 -d - > $out/password
                        '';
                      };
                    }) storageUsers
                  );

                  # Set up SMB passwords for users via systemd service
                  systemd.services."smb-setup-passwords-${instanceName}" = {
                    description = "Set up SMB passwords for ${instanceName} users";
                    after = [ "userborn.service" ];
                    before = [ "samba.target" ];
                    requiredBy = [ "samba.target" ];
                    serviceConfig = {
                      Type = "oneshot";
                      RemainAfterExit = true;
                    };
                    script =
                      let
                        # Ensure ownership of exported directories
                        ensureOwnershipCommands = lib.concatMapStringsSep "\n" (
                          export:
                          let
                            group = normalizedGroup export;
                            chmodGroupWrite = lib.optionalString (!export.readOnly) ''
                              chmod -R g+rwX "${export.path}"
                              find "${export.path}" -type d -exec chmod g+s {} +
                            '';
                          in
                          ''
                            mkdir -p "${export.path}"
                            if [ -d "${export.path}" ]; then
                              chown -R ${export.user}:${group} "${export.path}"
                              ${chmodGroupWrite}
                              echo "Set ownership of ${export.path} to ${export.user}:${group}"
                            fi
                          ''
                        ) flattenedExports;

                        addUserCommand = username: ''
                          password=$(cat ${
                            config.clan.core.vars.generators."smb-password-${instanceName}-${username}".files.password.path
                          })
                          (echo "$password"; echo "$password") | ${pkgs.samba}/bin/smbpasswd -a -s ${username}
                        '';
                      in
                      ''
                        # Ensure ownership of all exported directories
                        ${ensureOwnershipCommands}

                        # Add SMB users and passwords
                        ${lib.concatMapStringsSep "\n" addUserCommand storageUsers}
                      '';
                  };
                };
            };
        };

        client = {
          description = "Client that exports storage needs to be fulfilled by SMB server.";

          perInstance =
            {
              instanceName,
              machine,
              roles,
              ...
            }:
            let
              allExports = clanLib.selectExports (_scope: true) exports;
              storageExports = lib.filterAttrs (_scope: data: data ? storage && data.storage != null) allExports;
              storageUsers = lib.unique (lib.mapAttrsToList (_scope: data: data.storage.user) storageExports);

              # Flatten exports - each scope can have multiple directories
              flattenedExports = lib.flatten (
                lib.mapAttrsToList (
                  scope: data:
                  let
                    storage = data.storage;
                    exportsList = storage.exports;
                  in
                  lib.imap0 (idx: export: {
                    inherit scope;
                    inherit (storage) user group readOnly;
                    inherit (export) path mountPoint;
                    # Simple naming: user-0, user-1, etc.
                    shareName = "${storage.user}-${toString idx}";
                  }) exportsList
                ) storageExports
              );
            in
            {
              nixosModule =
                { config, pkgs, ... }:
                {
                  # Import the same generators to receive passwords from server
                  clan.core.vars.generators =
                    lib.listToAttrs (
                      map (username: {
                        name = "smb-password-${instanceName}-${username}";
                        value = {
                          share = true;
                          files.password = {
                            secret = true;
                            owner = "root";
                            mode = "0400";
                          };
                          runtimeInputs = [
                            pkgs.coreutils
                            pkgs.xkcdpass
                          ];
                          script = ''
                            xkcdpass -n 2 -d - > $out/password
                          '';
                        };
                      }) storageUsers
                    )
                    // lib.listToAttrs (
                      map (username: {
                        name = "smb-creds-${instanceName}-${username}";
                        value = {
                          share = false;
                          dependencies = [ "smb-password-${instanceName}-${username}" ];
                          files.creds = {
                            secret = true;
                            owner = "root";
                            mode = "0600";
                          };
                          runtimeInputs = [ pkgs.coreutils ];
                          script = ''
                            password=$(cat $in/smb-password-${instanceName}-${username}/password)
                            cat > $out/creds <<EOF
                            username=${username}
                            password=$password
                            EOF
                          '';
                        };
                      }) storageUsers
                    );

                  # Client configuration
                  environment.systemPackages = [ pkgs.cifs-utils ];

                  # Mount SMB shares based on storage exports from this machine
                  fileSystems = lib.listToAttrs (
                    map (
                      export:
                      let
                        serverMachine = "${
                          lib.head (lib.attrNames (roles.server.machines or { }))
                        }.${config.clan.core.settings.domain}";
                        credsPath =
                          config.clan.core.vars.generators."smb-creds-${instanceName}-${export.user}".files.creds.path;
                      in
                      lib.nameValuePair export.mountPoint {
                        device = "//${serverMachine}/${export.shareName}";
                        fsType = "cifs";
                        options = [
                          "credentials=${credsPath}"
                          "uid=${export.user}"
                          "gid=${if export.group != "" then export.group else export.user}"
                          "file_mode=0664"
                          "dir_mode=0775"
                          "x-systemd.automount"
                          "x-systemd.requires=network-online.target"
                        ]
                        ++ lib.optional export.readOnly "ro";
                      }
                    ) flattenedExports
                  );
                };
            };
        };
      };
    };
}
