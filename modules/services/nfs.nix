{ ... }:
{
  clan.inventory.instances.homelabNFS = {
    module.input = "self";
    module.name = "nfs";
    # roles.server.machines.agentn = { };
    # roles.client.machines.agentc = { };
  };

  clan.modules.nfs =
    { lib, ... }:
    {
      _class = "clan.service";
      manifest.name = "nfs";
      manifest.readme = "NFS storage service with automatic export management.";

      roles.server = {
        description = "NFSv4 server that auto-discovers and exports client mounts.";
        perInstance =
          { roles, ... }:
          {
            nixosModule =
              { config, lib, ... }:
              let
                clientMachines = roles.client.machines or { };

                allClientMounts = lib.flatten (
                  lib.mapAttrsToList (
                    clientName: clientConfig:
                    map (mount: mount // { clientMachine = clientName; }) (clientConfig.settings.mounts or [ ])
                  ) clientMachines
                );

                myMounts = lib.filter (m: m.serverMachine == config.networking.hostName) allClientMounts;
              in
              {
                services.nfs.server = {
                  enable = true;
                  createMountPoints = true;
                  exports = lib.concatStringsSep "\n" (
                    map (mount: "${mount.remotePath} ${mount.clientMachine}(rw,sync,no_subtree_check)") myMounts
                  );
                };

                networking.firewall.allowedTCPPorts = [ 2049 ];
              };
          };
      };

      roles.client = {
        description = "NFS client that declares mount requirements.";

        interface = {
          options.mounts = lib.mkOption {
            type = lib.types.listOf (
              lib.types.submodule {
                options = {
                  localPath = lib.mkOption {
                    type = lib.types.str;
                    description = "Path where NFS mount appears on client";
                  };
                  remotePath = lib.mkOption {
                    type = lib.types.str;
                    description = "Path on NFS server to export";
                  };
                  serverMachine = lib.mkOption {
                    type = lib.types.str;
                    description = "Hostname of NFS server (must be in roles.server.machines)";
                  };
                };
              }
            );
            default = [ ];
          };
        };

        perInstance =
          {
            settings,
            machine,
            roles,
            ...
          }:
          let
            serverMachines = lib.attrNames (roles.server.machines or { });

            validateMount =
              mount:
              let
                isValidServer = lib.elem mount.serverMachine serverMachines;
              in
              lib.throwIf (!isValidServer) ''
                NFS client error: serverMachine '${mount.serverMachine}' is not a valid NFS server.
                Available servers: ${lib.concatStringsSep ", " serverMachines}
              '' mount;

            validatedMounts = map validateMount settings.mounts;
          in
          {
            nixosModule =
              { lib, ... }:
              {
                fileSystems = lib.listToAttrs (
                  map (mount: {
                    name = mount.localPath;
                    value = {
                      device = "${mount.serverMachine}:${mount.remotePath}";
                      fsType = "nfs4";
                      options = [
                        "vers=4.2"
                        "hard"
                        "intr"
                      ];
                    };
                  }) validatedMounts
                );
              };
          };
      };
    };
}
