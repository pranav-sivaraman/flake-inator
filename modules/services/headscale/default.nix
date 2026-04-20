_: {

  clan.inventory.instances.headscale = {
    module.input = "self";
    module.name = "headscale";

    roles.server.machines.agentc = { };
  };

  clan.modules.headscale = {
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
                lib,
                ...
              }:
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

                environment.persistence."/persist".directories = [
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
                    dns = {
                      magic_dns = true;
                      base_domain = "ts.${config.clan.core.settings.domain}";
                      nameservers.global = [ "192.168.1.1" ];
                    };
                    oidc = {
                      issuer = "https://pocket-id.${config.clan.core.settings.domain}";
                      client_id = "598c195e-0712-451c-96a2-e9cd39c4bec3";
                      client_secret_path = config.clan.core.vars.generators."headscale-oidc".files.secret.path;
                      pkce = {
                        enabled = true;
                        method = "S256";
                      };
                    };
                  };
                };
              };
          };
      };
    };
  };
}
