{ ... }:
{
  clan.inventory.instances.publicProxy = {
    module.input = "self";
    module.name = "reverseProxy";

    roles.server.machines.agentc = {
    };
  };

  clan.modules.reverseProxy =
    {
      clanLib,
      lib,
      exports,
      ...
    }:
    {
      _class = "clan.service";
      manifest.name = "reverseProxy";

      roles = {
        server = {
          perInstance =
            {
              instanceName,
              roles,
              ...
            }:
            {
              nixosModule =
                {
                  config,
                  pkgs,
                  lib,
                  ...
                }:
                let
                  allExports = clanLib.selectExports (_scope: true) exports;
                  # Filter for exports that have a non-null route
                  routeExports = lib.filterAttrs (_scope: data: data ? route && data.route != null) allExports;

                  handleBlocks = lib.concatStringsSep "\n\n" (
                    lib.mapAttrsToList (
                      _scope: data:
                      let
                        route = data.route;
                      in
                      ''
                        @${route.subdomain} host ${route.subdomain}.${config.clan.core.settings.domain}
                        handle @${route.subdomain} {
                          reverse_proxy http://${route.interface}:${toString route.port}
                        }
                      ''
                    ) routeExports
                  );

                  caddyfile = pkgs.writeText "Caddyfile" (''
                    {
                        skip_install_trust
                    }

                    https://*.${config.clan.core.settings.domain} {
                        tls {
                          dns cloudflare {env.CF_API_TOKEN}
                          resolvers 1.1.1.1 # TODO change
                        }

                        ${handleBlocks}
                    }
                  '');

                  caddyWithCloudflare = pkgs.caddy.withPlugins {
                    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
                    hash = "sha256-dnhEjopeA0UiI+XVYHYpsjcEI6Y1Hacbi28hVKYQURg=";
                  };
                in
                {
                  clan.core.vars.generators."caddy-cf-token-${instanceName}" = {
                    prompts.cf-token = {
                      description = "Cloudflare API token for ${config.clan.core.settings.domain}";
                      type = "hidden";
                    };
                    files.env = {
                      secret = true;
                      owner = "caddy";
                      mode = "0400";
                    };
                    runtimeInputs = [ pkgs.coreutils ];
                    script = ''
                      echo "CF_API_TOKEN=$(cat $prompts/cf-token)" > $out/env
                    '';
                  };

                  services.caddy = {
                    enable = true;
                    package = caddyWithCloudflare;
                    configFile = caddyfile;
                    environmentFile = config.clan.core.vars.generators."caddy-cf-token-${instanceName}".files.env.path;
                  };

                  networking.firewall.allowedTCPPorts = [ 443 ];

                  environment.persistence."/persist".directories = [
                    {
                      directory = config.services.caddy.dataDir;
                      user = config.services.caddy.user;
                      group = config.services.caddy.group;
                    }
                  ];

                };
            };
        };
      };
    };
}
