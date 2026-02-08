{

  clan.inventory.instances.immich = {
    module.input = "self";
    module.name = "immich";

    roles.server.machines.agentc = { };
  };
  clan.modules.immich =
    { clanLib, lib, ... }:
    {
      _class = "clan.service";
      manifest.name = "immich";
      manifest.readme = "Immich self-hosted photo and video backup solution with SMB storage.";

      roles = {
        server = {
          description = "Runs the Immich photo and video management server.";
          perInstance =
            {
              mkExports,
              ...
            }:
            {
              exports = mkExports {
                storage =
                  let
                    baseServerPath = "/persist/var/lib/immich";
                    baseClientPath = "/var/lib/immich";
                    dirs = [
                      "backups"
                      "encoded-video"
                      "library"
                      "profile"
                      "thumbs"
                      "upload"
                    ];
                  in
                  {
                    exports = map (dir: {
                      path = "${baseServerPath}/${dir}";
                      mountPoint = "${baseClientPath}/${dir}";
                    }) dirs;
                    user = "immich";
                    group = "immich";
                    readOnly = false;
                  };
                route = {
                  subdomain = "photos";
                  interface = "localhost";
                  port = "2283";
                };
              };

              nixosModule =
                {
                  config,
                  pkgs,
                  lib,
                  ...
                }:
                {
                  services.immich = {
                    enable = true;
                    openFirewall = true;
                  };

                  services.postgresql = {
                    package = pkgs.postgresql_14; # Remove once immich creates a DB backup on the latest version
                  };

                  environment.persistence."/persist".directories = [
                    {
                      directory = "/var/lib/redis-immich";
                      user = "redis-immich";
                      group = "redis-immich";
                      mode = "0700";
                    }
                    # {
                    #   directory = "/var/lib/immich";
                    #   user = "immich";
                    #   group = "immich";
                    #   mode = "0700";
                    # }
                  ];
                };
            };
        };
      };
    };
}
