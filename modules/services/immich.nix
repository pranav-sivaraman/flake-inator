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
                storage = {
                  path = "/persist/var/lib/immich";
                  mountPoint = "/var/lib/immich";
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
                { config, pkgs, ... }:
                {
                  services.immich = {
                    enable = true;
                    openFirewall = true;
                  };

                  services.postgresql = {
                    enable = true;
                    package = pkgs.postgresql_14;
                  };

                  environment.persistence."/persist".directories = [
                    {
                      directory = "/var/lib/postgresql";
                      user = "postgres";
                      group = "postgres";
                      mode = "0750";
                    }
                    {
                      directory = "/var/lib/redis-immich";
                      user = "redis-immich";
                      group = "redis-immich";
                      mode = "0700";
                    }
                  ];
                };
            };
        };
      };
    };
}
