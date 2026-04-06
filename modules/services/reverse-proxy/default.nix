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
      manifest.readme = "Caddy reverse proxy with automatic HTTPS and Cloudflare DNS integration.";

      roles = {
        server = {
          description = "Runs the Caddy reverse proxy server with TLS termination.";
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
                        isPublic = route.public or false;
                      in
                      ''
                        @${route.subdomain} host ${route.subdomain}.${config.clan.core.settings.domain}
                        handle @${route.subdomain} {
                          ${lib.optionalString (!isPublic) ''
                          @not_private not remote_ip private_ranges
                          handle @not_private {
                            respond "Access denied" 403
                          }
                          ''}
                          reverse_proxy http://${route.machineName}.${config.clan.core.settings.domain}:${toString route.port}
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

                        header {
                          # Force HTTPS for 1 year, include subdomains
                          Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
                          # Prevent clickjacking
                          X-Frame-Options "SAMEORIGIN"
                          # Prevent MIME type sniffing
                          X-Content-Type-Options "nosniff"
                          # Control referrer information
                          Referrer-Policy "strict-origin-when-cross-origin"
                          # Restrict browser features
                          Permissions-Policy "geolocation=(), camera=(), microphone=(), payment=(), usb=(), interest-cohort=()"
                          # Basic CSP — tighten per-service as needed
                          Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; object-src 'none'; frame-ancestors 'self'; base-uri 'self'; form-action 'self'"
                          # Cross-Origin isolation headers
                          Cross-Origin-Embedder-Policy "require-corp"
                          Cross-Origin-Opener-Policy "same-origin"
                          Cross-Origin-Resource-Policy "same-origin"
                          # Remove server fingerprinting
                          -Server
                        }

                        ${handleBlocks}

                        # Temporary public hello page for testing internet exposure.
                        # Remove this block when no longer needed.
                        @hello host hello.${config.clan.core.settings.domain}
                        handle @hello {
                          respond "Hello from {host}!" 200
                        }
                    }
                  '');

                  caddyWithCloudflare = pkgs.caddy.withPlugins {
                    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
                    hash = "sha256-Gb1nC5fZfj7IodQmKmEPGygIHNYhKWV1L0JJiqnVtbs=";
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
