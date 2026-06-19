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
              ...
            }:
            {
              nixosModule =
                {
                  config,
                  pkgs,
                  lib,
                  self,
                  ...
                }:
                let
                  allExports = clanLib.selectExports (_scope: true) exports;
                  # Filter for exports that have a non-null route
                  routeExports = lib.filterAttrs (_scope: data: data ? route && data.route != null) allExports;

                  mkHandleBlock =
                    data:
                    let
                      inherit (data) route;
                      upstreamHost = self.nixosConfigurations.${route.machineName}.config.networking.primaryIp;
                    in
                    ''
                      @${route.subdomain} host ${route.subdomain}.${config.clan.core.settings.domain}
                      handle @${route.subdomain} {
                        reverse_proxy http://${upstreamHost}:${toString route.port}
                      }
                    '';

                  publicHandleBlocks = lib.concatStringsSep "\n\n" (
                    lib.mapAttrsToList (_scope: data: mkHandleBlock data) (
                      lib.filterAttrs (_scope: data: data.route.public or false) routeExports
                    )
                  );

                  privateHandleBlocks = lib.concatStringsSep "\n\n" (
                    lib.mapAttrsToList (_scope: data: mkHandleBlock data) (
                      lib.filterAttrs (_scope: data: !(data.route.public or false)) routeExports
                    )
                  );

                  privateAllowedRanges = [
                    "private_ranges"
                    "100.64.0.0/10"
                  ];

                  privateAccessGuard = lib.optionalString (privateHandleBlocks != "") ''
                    @non_private not remote_ip ${lib.concatStringsSep " " privateAllowedRanges}
                    handle @non_private {
                      respond "Access denied" 403
                    }
                  '';

                  rawCaddyfile = pkgs.writeText "Caddyfile.unformatted" ''
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
                          #Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; object-src 'none'; frame-ancestors 'self'; base-uri 'self'; form-action 'self'"
                          # Cross-Origin isolation headers
                          # Cross-Origin-Embedder-Policy "require-corp"
                          # Cross-Origin-Opener-Policy "same-origin"
                          # Cross-Origin-Resource-Policy "same-origin"
                          # Remove server fingerprinting
                          -Server
                        }

                        ${publicHandleBlocks}

                        ${privateAccessGuard}

                        ${privateHandleBlocks}
                    }
                  '';

                  caddyfile = pkgs.runCommand "Caddyfile" { nativeBuildInputs = [ pkgs.caddy ]; } ''
                    tmp="$TMPDIR/Caddyfile"
                    cp ${rawCaddyfile} "$tmp"
                    chmod u+w "$tmp"
                    caddy fmt --overwrite "$tmp"
                    cp "$tmp" "$out"
                  '';

                  caddyWithCloudflare = pkgs.caddy.withPlugins {
                    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
                    hash = "sha256-wHW0l15aLswe7gV9WioXo//abd0sJI82I7zIroRG3uU=";
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

                  preservation.preserveAt."/persist".directories = [
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
