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

              shareConfigs = lib.mapAttrs' (
                scope: data:
                let
                  storage = data.storage;
                  shareName = lib.replaceStrings [ "." "/" ] [ "-" "-" ] scope;
                  group = if storage.group != "" then storage.group else storage.user;
                in
                lib.nameValuePair shareName {
                  path = storage.path;
                  "valid users" = storage.user;
                  "write list" = lib.mkIf (!storage.readOnly) storage.user;
                  "read only" = if storage.readOnly then "yes" else "no";
                  browseable = "yes";
                  "guest ok" = "no";
                  "create mask" = "0644";
                  "directory mask" = "0755";
                  "force user" = storage.user;
                  "force group" = group;
                }
              ) storageExports;
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
                        description = "SMB user for ${username}";
                      };
                    }) storageUsers
                  );

                  users.groups = lib.listToAttrs (
                    map (username: {
                      name = username;
                      value = { };
                    }) storageUsers
                  );

                  # Persist samba state only
                  environment.persistence."/persist".directories = [
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
                          xkcdpass -n 6 -d - > $out/password
                        '';
                      };
                    }) storageUsers
                  );

                  # Set up SMB passwords for users via systemd service
                  systemd.services."smb-setup-passwords-${instanceName}" = {
                    description = "Set up SMB passwords for ${instanceName} users";
                    before = [ "samba.target" ];
                    requiredBy = [ "samba.target" ];
                    serviceConfig = {
                      Type = "oneshot";
                      RemainAfterExit = true;
                    };
                    script =
                      let
                        addUserCommand = username: ''
                          password=$(cat ${
                            config.clan.core.vars.generators."smb-password-${instanceName}-${username}".files.password.path
                          })
                          (echo "$password"; echo "$password") | ${pkgs.samba}/bin/smbpasswd -a -s ${username}
                        '';
                      in
                      lib.concatMapStringsSep "\n" addUserCommand storageUsers;
                  };
                };
            };
        };

        client = {
          description = "Client that exports storage needs to be fulfilled by SMB server.";

          perInstance =
            {
              instanceName,
              mkExports,
              machine,
              roles,
              ...
            }:
            let
              allExports = clanLib.selectExports (_scope: true) exports;
              storageExports = lib.filterAttrs (_scope: data: data ? storage && data.storage != null) allExports;
              storageUsers = lib.unique (lib.mapAttrsToList (_scope: data: data.storage.user) storageExports);
            in
            {
              exports = mkExports { };

              nixosModule =
                { config, pkgs, ... }:
                {
                  # Import the same generators to receive passwords from server
                  clan.core.vars.generators = lib.listToAttrs (
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
                          xkcdpass -n 6 -d - > $out/password
                        '';
                      };
                    }) storageUsers
                  );

                  # Client configuration
                  environment.systemPackages = [ pkgs.cifs-utils ];

                  # Mount SMB shares based on storage exports from this machine
                  fileSystems = lib.mapAttrs' (
                    scope: data:
                    let
                      storage = data.storage;
                      shareName = lib.replaceStrings [ "." "/" ] [ "-" "-" ] scope;
                      # TODO: Replace .lan suffix with proper networking/DNS resolution
                      # Get server machine name from roles and add .lan suffix
                      serverMachine = "${lib.head (lib.attrNames (roles.server.machines or { }))}.lan";
                    in
                    lib.nameValuePair storage.mountPoint {
                      device = "//${serverMachine}/${shareName}";
                      fsType = "cifs";
                      options = [
                        "credentials=/run/secrets/smb-${instanceName}-${storage.user}.creds"
                        "uid=${storage.user}"
                        "gid=${if storage.group != "" then storage.group else storage.user}"
                        "file_mode=0644"
                        "dir_mode=0755"
                        "x-systemd.automount"
                        "x-systemd.idle-timeout=60"
                        "x-systemd.requires=network-online.target"
                      ];
                    }
                  ) storageExports;

                  # Create credentials files for SMB mounts via systemd services
                  systemd.services = lib.mapAttrs' (
                    _scope: data:
                    let
                      storage = data.storage;
                      credsFile = "/run/secrets/smb-${instanceName}-${storage.user}.creds";
                      passwordPath =
                        config.clan.core.vars.generators."smb-password-${instanceName}-${storage.user}".files.password.path;
                      mountUnit = "${lib.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" storage.mountPoint)}.mount";
                    in
                    lib.nameValuePair "smb-creds-${instanceName}-${storage.user}" {
                      description = "Create SMB credentials for ${storage.user}";
                      before = [ mountUnit ];
                      requiredBy = [ mountUnit ];
                      serviceConfig = {
                        Type = "oneshot";
                        RemainAfterExit = true;
                      };
                      script = ''
                        mkdir -p /run/secrets
                        cat > ${credsFile} <<EOF
                        username=${storage.user}
                        password=$(cat ${passwordPath})
                        EOF
                        chmod 600 ${credsFile}
                      '';
                    }
                  ) storageExports;
                };
            };
        };
      };
    };
}
