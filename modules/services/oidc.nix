{ ... }:
{

  clan.inventory.instances.oidc = {
    module.input = "self";
    module.name = "oidc";

    roles.server.machines.agentc = {
    };
  };

  clan.inventory.instances.publicProxy = {
    roles.service.machines.agentc = {
      settings.routes = [
        {
          subdomain = "pocket-id";
          backend = "192.168.1.3:1411";
          proxyServer = "agentc";
        }
      ];
    };
  };
  clan.modules.oidc = {
    _class = "clan.service";
    manifest.name = "oidc";

    roles = {
      server = {
        perInstance = {
          nixosModule =
            { config, pkgs, ... }:
            {
              clan.core.vars.generators."pocket-id-encryption-key" = {
                files.key = {
                  secret = true;
                  owner = "pocket-id";
                  mode = "0400";
                };
                runtimeInputs = [
                  pkgs.coreutils
                  pkgs.openssl
                ];
                script = ''
                  openssl rand -base64 32 > $out/key
                '';
              };
              services.pocket-id = {
                enable = true;
                settings = {
                  TRUST_PROXY = true;
                  APP_URL = "https://pocket-id.praarthana.space";
                  ANALYTICS_DISABLED = true;
                };
                credentials = {
                  ENCRYPTION_KEY = config.clan.core.vars.generators.pocket-id-encryption-key.files.key.path;
                };
              };

              environment.persistence."/persist".directories = [
                {
                  directory = config.services.pocket-id.dataDir;
                  user = config.services.pocket-id.user;
                  group = config.services.pocket-id.group;
                }
              ];

              networking.firewall.allowedTCPPorts = [ 1411 ];
            };
        };
      };
    };
  };
}
