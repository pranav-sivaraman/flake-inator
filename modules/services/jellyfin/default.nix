{
  clan.inventory.instances.jellyfin = {
    module.input = "self";
    module.name = "jellyfin";

    roles.server.machines.agentc = { };
  };

  clan.modules.jellyfin = {
    _class = "clan.service";
    manifest = {
      name = "jellyfin";
      readme = "Jellyfin media server with SMB media storage.";
      exports.out = [
        "route"
        "storage"
      ];
    };

    roles = {
      server = {
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
    };
  };
}
