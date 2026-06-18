{
  clan.inventory.instances = {
    jellyfin = {
      module.input = "self";
      module.name = "servarr";

      roles.jellyfin.machines.agentc = { };
    };

    seerr = {
      module.input = "self";
      module.name = "servarr";

      roles.seerr.machines.agentc = { };
    };

    sonarr = {
      module.input = "self";
      module.name = "servarr";

      roles.sonarr.machines.agentc = { };
    };

    radarr = {
      module.input = "self";
      module.name = "servarr";

      roles.radarr.machines.agentc = { };
    };

    prowlarr = {
      module.input = "self";
      module.name = "servarr";

      roles.prowlarr.machines.agentc = { };
    };

    sabnzbd = {
      module.input = "self";
      module.name = "servarr";

      roles.sabnzbd.machines.agentc = { };
    };
  };

  clan.modules.servarr = {
    _class = "clan.service";
    manifest = {
      name = "servarr";
      readme = "Servarr stack.";
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
                group = "media";
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
                users.groups.media = { };

                services.jellyfin = {
                  enable = true;
                  dataDir = jellyfinDataDir;
                  group = "media";
                };

                environment.persistence."/persist".directories = [
                  {
                    directory = cfg.dataDir;
                    inherit (cfg) user group;
                    mode = "0750";
                  }
                  {
                    directory = mediaDir;
                    user = "jellyfin";
                    group = "media";
                    mode = "2770";
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

      sonarr = {
        description = "Runs Sonarr.";
        perInstance =
          { mkExports, machine, ... }:
          let
            subdomain = "sonarr";
            port = 8989;
          in
          {
            exports = mkExports {
              route = {
                inherit subdomain port;
                machineName = machine.name;
              };
            };

            nixosModule =
              { config, ... }:
              let
                cfg = config.services.sonarr;
              in
              {
                users.groups.media = { };

                services.sonarr = {
                  enable = true;
                  group = "media";
                };

                environment.persistence."/persist".directories = [
                  {
                    directory = cfg.dataDir;
                    inherit (cfg) user group;
                    mode = "0710";
                  }
                ];
              };
          };
      };

      radarr = {
        description = "Runs Radarr.";
        perInstance =
          { mkExports, machine, ... }:
          let
            subdomain = "radarr";
            port = 7878;
          in
          {
            exports = mkExports {
              route = {
                inherit subdomain port;
                machineName = machine.name;
              };
            };

            nixosModule =
              { config, ... }:
              let
                cfg = config.services.radarr;
              in
              {
                users.groups.media = { };

                services.radarr = {
                  enable = true;
                  group = "media";
                };

                environment.persistence."/persist".directories = [
                  {
                    directory = cfg.dataDir;
                    inherit (cfg) user group;
                    mode = "0710";
                  }
                ];
              };
          };
      };

      prowlarr = {
        description = "Runs Prowlarr.";
        perInstance =
          { mkExports, machine, ... }:
          let
            subdomain = "prowlarr";
            port = 9696;
          in
          {
            exports = mkExports {
              route = {
                inherit subdomain port;
                machineName = machine.name;
              };
            };

            nixosModule = {
              services.prowlarr.enable = true;

              environment.persistence."/persist".directories = [
                {
                  directory = "/var/lib/private/prowlarr";
                  user = "root";
                  group = "root";
                  mode = "0700";
                }
              ];
            };
          };
      };

      sabnzbd = {
        description = "Runs SABnzbd.";
        perInstance =
          { mkExports, machine, ... }:
          let
            subdomain = "sabnzbd";
            port = 8081;
          in
          {
            exports = mkExports {
              route = {
                inherit subdomain port;
                machineName = machine.name;
              };
            };

            nixosModule =
              { config, ... }:
              let
                cfg = config.services.sabnzbd;
              in
              {
                users.groups.media = { };

                services.sabnzbd = {
                  enable = true;
                  configFile = null;
                  group = "media";
                  allowConfigWrite = true;
                  settings.misc = {
                    host = "0.0.0.0";
                    inherit port;
                    inet_exposure = "api+web (auth needed)";
                    host_whitelist = "sabnzbd.praarthana.space,localhost,127.0.0.1";
                    permissions = "775";
                  };
                };

                environment.persistence."/persist".directories = [
                  {
                    directory = "/var/lib/${cfg.stateDir}";
                    inherit (cfg) user group;
                    mode = "0750";
                  }
                ];
              };
          };
      };
    };
  };
}
