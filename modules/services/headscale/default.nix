{ ... }:
{

  clan.inventory.instances.headscale = {
    module.input = "self";
    module.name = "headscale";

    roles.server.machines.agentc = { };
  };

  clan.modules.headscale =
    {
      clanLib,
      lib,
      exports,
      ...
    }:
    {
      _class = "clan.service";
      manifest = {
        name = "headscale";
        readme = "Headscale is an open-source, self-hosted implementation of the Tailscale control server.";
        exports.out = [ "route" ];
      };

      roles = {
        server = {
          description = "Runs the Headscale server.";
          perInstance =
            { mkExports, machine, ... }:
            let
              subdomain = "headscale";
              port = 8080;
            in
            {
              exports = mkExports {
                route = {
                  inherit subdomain port;
                  machineName = machine.name;
                  public = true;
                };
              };

              nixosModule =
                {
                  config,
                  pkgs,
                  ...
                }:
                let
                  allExports = clanLib.selectExports (_scope: true) exports;
                  routeExports = lib.filterAttrs (_scope: data: data ? route && data.route != null) allExports;
                  privateRouteExports = lib.filterAttrs (_scope: data: !(data.route.public or false)) routeExports;
                  internalCaddyIp = config.networking.headscaleIp;
                in
                {
                  clan.core.vars.generators."headscale-oidc" = {
                    prompts.client-secret = {
                      description = "OpenID Connect Client Secret for Headscale";
                      type = "hidden";
                    };
                    files.secret = {
                      secret = true;
                      owner = config.services.headscale.user;
                      mode = "0400";
                    };
                    runtimeInputs = [ pkgs.coreutils ];
                    script = ''
                      cat $prompts/client-secret > $out/secret
                    '';
                  };

                  preservation.preserveAt."/persist".directories = [
                    {
                      directory = "/var/lib/headscale";
                      user = "headscale";
                      group = "headscale";
                      mode = "0750";
                    }
                  ];

                  services.headscale = {
                    enable = true;
                    settings = {
                      server_url = "https://${subdomain}.${config.clan.core.settings.domain}";
                      listen_addr = "${config.networking.primaryIp}:${toString port}";
                      oidc = {
                        issuer = "https://pocket-id.${config.clan.core.settings.domain}";
                        client_id = "598c195e-0712-451c-96a2-e9cd39c4bec3";
                        client_secret_path = config.clan.core.vars.generators."headscale-oidc".files.secret.path;
                        pkce = {
                          enabled = true;
                          method = "S256";
                        };
                      };
                      # MagicDNS domain must not contain the Headscale server URL
                      # (server_url is headscale.${config.clan.core.settings.domain}).
                      dns.base_domain = "tailnet.${config.clan.core.settings.domain}";
                      dns.nameservers.global = [
                        "1.1.1.1"
                        "8.8.8.8"
                      ];
                      dns.extra_records = lib.mapAttrsToList (_scope: data: {
                        name = "${data.route.subdomain}.${config.clan.core.settings.domain}";
                        type = "A";
                        value = internalCaddyIp;
                      }) privateRouteExports;
                    };
                  };
                };
            };
        };
      };
    };
}
