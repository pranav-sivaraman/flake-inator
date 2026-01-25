{ clanLib, lib, ... }:
{
  clan.inventory.instances.publicProxy = {
    module.input = "self";
    module.name = "reverseProxy";

    roles.server.machines.agentc = {
      settings.domain = "praarthana.space";
    };
    roles.service.machines.agentc = { };
    roles.service.machines.agentn = { };
  };

  clan.modules.reverseProxy =
    { lib, ... }:
    {
      _class = "clan.service";
      manifest.name = "reverseProxy";
      manifest.readme = ''
        Caddy-based reverse proxy with automatic HTTPS via Cloudflare DNS.

        ## Roles

        **Server Role**: Auto-discovers services and generates Caddyfile
        - Configure with base domain for wildcard certificates
        - Manages TLS via Cloudflare DNS-01 challenges
        - Handles subdomain routing to backend services

        **Service Role**: Declares subdomain routing requirements
        - Specify subdomain, backend target, and proxy server
        - Supports container names or IP:port backends
        - Optional custom Caddy directives per route

        ## Usage

        See examples/vaultwarden-proxy-example.nix for integration pattern.

        ## Secrets

        Requires Cloudflare API token with DNS edit permissions.
        Token is prompted during deployment and stored securely.
      '';

      roles = {
        service = {
          description = "Machine hosting services that need reverse proxying";

          interface = {
            options.routes = lib.mkOption {
              type = lib.types.listOf (
                lib.types.submodule {
                  options = {
                    subdomain = lib.mkOption {
                      type = lib.types.str;
                      description = "Subdomain for this service";
                      example = "passwords";
                    };

                    backend = lib.mkOption {
                      type = lib.types.str;
                      description = "Backend target (IP:port or container name)";
                      example = "http://192.168.1.2:8080 or http://vaultwarden:80";
                    };

                    proxyServer = lib.mkOption {
                      type = lib.types.str;
                      description = "Hostname of the reverse proxy server";
                    };

                    extraDirectives = lib.mkOption {
                      type = lib.types.lines;
                      default = "";
                      description = "Additional Caddy directives for this route";
                    };
                  };
                }
              );
              default = [ ];
              description = "List of routes to configure on the proxy server";
            };
          };
        };

        server = {
          description = "Caddy reverse proxy server with automatic TLS";

          interface = {
            options.domain = lib.mkOption {
              type = lib.types.str;
              description = "Base domain for wildcard certificate";
              example = "praarthana.space";
            };
          };

          perInstance =
            {
              roles,
              instanceName,
              settings,
              ...
            }:
            {
              nixosModule =
                {
                  config,
                  lib,
                  pkgs,
                  ...
                }:
                let
                  serviceMachines = roles.service.machines or { };
                  serverMachines = lib.attrNames (roles.server.machines or { });

                  allRoutes = lib.flatten (
                    lib.mapAttrsToList (
                      machineName: machineConfig:
                      map (route: route // { sourceMachine = machineName; }) (machineConfig.settings.routes or [ ])
                    ) serviceMachines
                  );

                  validateRoute =
                    route:
                    lib.throwIf (!lib.elem route.proxyServer serverMachines) ''
                      Reverse proxy error: proxyServer '${route.proxyServer}' is not valid.
                      Available proxy servers: ${lib.concatStringsSep ", " serverMachines}
                    '' route;

                  validatedRoutes = map validateRoute allRoutes;

                  myRoutes = lib.filter (r: r.proxyServer == config.networking.hostName) validatedRoutes;

                  subdomainCounts = lib.groupBy (r: r.subdomain) myRoutes;
                  duplicates = lib.filterAttrs (subdomain: routes: lib.length routes > 1) subdomainCounts;

                  generateHandle = idx: route: ''
                    @route_${toString idx} host ${route.subdomain}.${settings.domain}
                    handle @route_${toString idx} {
                      reverse_proxy ${route.backend}
                      ${route.extraDirectives}
                    }
                  '';

                  caddyfile = pkgs.writeText "Caddyfile" ''
                    {
                      skip_install_trust
                    }

                    https://*.${settings.domain} {
                      tls {
                        dns cloudflare {env.CF_API_TOKEN}
                        resolvers 1.1.1.1
                      }

                      ${lib.concatImapStringsSep "\n" generateHandle myRoutes}
                    }
                  '';

                  caddyWithCloudflare = pkgs.caddy.withPlugins {
                    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
                    hash = "sha256-dnhEjopeA0UiI+XVYHYpsjcEI6Y1Hacbi28hVKYQURg=";
                  };
                in
                {
                  assertions = [
                    {
                      assertion = duplicates == { };
                      message = ''
                        Duplicate subdomains detected in reverse proxy:
                        ${lib.concatStringsSep "\n" (
                          lib.mapAttrsToList (
                            subdomain: routes: "  - ${subdomain}: used by ${toString (lib.length routes)} routes"
                          ) duplicates
                        )}
                      '';
                    }
                  ];

                  clan.core.vars.generators."caddy-cf-token-${instanceName}" = {
                    prompts.cf-token = {
                      description = "Cloudflare API token for ${settings.domain}";
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
                };
            };
        };
      };
    };
}
