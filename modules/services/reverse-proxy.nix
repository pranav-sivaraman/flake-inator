{
  clanLib,
  lib,
  config,
  ...
}:
{
  options.flake.routes = lib.mkOption {
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          subdomain = lib.mkOption {
            type = lib.types.str;
            description = "Subdomain for this service";
            example = "photos";
          };

          backend = lib.mkOption {
            type = lib.types.str;
            description = "Backend target (IP:port or container name)";
            example = "http://192.168.1.2:8080";
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
    description = "Routes to be configured on the reverse proxy. Each service file can append to this list.";
  };

  config = {
    clan.inventory.instances.publicProxy = {
      module.input = "self";
      module.name = "reverseProxy";

      roles.server.machines.agentc = {
        settings = {
          domain = "praarthana.space";
          # Collect routes from flake-level option
          routes = config.flake.routes or [ ];
        };
      };
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
          - Routes are collected from the flake-level `flake.routes` option

          ## Usage

          Services declare routes using the flake-level `flake.routes` option:

          ```nix
          flake.routes = [
            {
              subdomain = "myservice";
              backend = "http://192.168.1.2:8080";
              proxyServer = "agentc";
              extraDirectives = ""; # optional
            }
          ];
          ```

          Each service file can independently add routes without conflicts.

          ## Secrets

          Requires Cloudflare API token with DNS edit permissions.
          Token is prompted during deployment and stored securely.
        '';

        roles = {
          server = {
            description = "Caddy reverse proxy server with automatic TLS";

            interface = {
              options.domain = lib.mkOption {
                type = lib.types.str;
                description = "Base domain for wildcard certificate";
                example = "praarthana.space";
              };

              options.routes = lib.mkOption {
                type = lib.types.listOf (
                  lib.types.submodule {
                    options = {
                      subdomain = lib.mkOption {
                        type = lib.types.str;
                        description = "Subdomain for this service";
                      };

                      backend = lib.mkOption {
                        type = lib.types.str;
                        description = "Backend target (IP:port or container name)";
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
                description = "Routes to configure (injected from flake.routes)";
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
                    serverMachines = lib.attrNames (roles.server.machines or { });

                    # Get routes from settings (injected from flake.routes)
                    allRoutes = settings.routes or [ ];

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

                    environment.persistence."/persist".directories = [
                      {
                        directory = config.services.caddy.dataDir;
                        user = config.services.caddy.user;
                        group = config.services.caddy.group;
                      }
                    ];

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
  };
}
