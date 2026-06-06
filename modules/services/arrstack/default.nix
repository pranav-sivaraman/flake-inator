{
  clan.inventory.instances = {
    jellyfin = {
      module.input = "self";
      module.name = "arrstack";

      roles.jellyfin.machines.agentc = { };
    };

    seerr = {
      module.input = "self";
      module.name = "arrstack";

      roles.seerr.machines.agentc = { };
    };
  };

  clan.modules.arrstack = {
    _class = "clan.service";
    manifest = {
      name = "arrstack";
      readme = "Jellyfin media server and Seerr request manager stack.";
      exports.out = [
        "route"
        "storage"
      ];
    };

    roles = {
      jellyfin = {
        description = "Runs the Jellyfin media server.";
        perInstance =
          {
            mkExports,
            machine,
            ...
          }:
          let
            subdomain = "jellyfin";
            jellyfinDataDir = "/var/lib/jellyfin";
            mediaDir = "${jellyfinDataDir}/media";
          in
          {
            exports = mkExports {
              storage = {
                exports = [
                  {
                    path = "/persist${mediaDir}";
                    mountPoint = mediaDir;
                  }
                ];
                user = "jellyfin";
                group = "jellyfin";
                readOnly = false;
              };
              route = {
                inherit subdomain;
                machineName = machine.name;
                port = 8096;
              };
            };

            nixosModule =
              { config, ... }:
              let
                cfg = config.services.jellyfin;
              in
              {
                services.jellyfin = {
                  enable = true;
                  dataDir = jellyfinDataDir;
                };

                environment.persistence."/persist".directories = [
                  {
                    directory = cfg.dataDir;
                    inherit (cfg) user group;
                    mode = "0700";
                  }
                ];
              };
          };
      };

      seerr = {
        description = "Runs the Seerr request manager.";
        perInstance =
          { mkExports, machine, ... }:
          let
            subdomain = "seerr";
            port = 5055;
          in
          {
            exports = mkExports {
              route = {
                inherit subdomain port;
                machineName = machine.name;
              };
            };

            nixosModule = {
              services.seerr = {
                enable = true;
                inherit port;
              };

              environment.persistence."/persist".directories = [
                {
                  directory = "/var/lib/private/seerr";
                  user = "root";
                  group = "root";
                  mode = "0700";
                }
              ];
            };
          };
      };
    };
  };
}
