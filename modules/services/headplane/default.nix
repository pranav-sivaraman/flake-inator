{ inputs, ... }:
{
  clan.inventory.instances.headplane = {
    module.input = "self";
    module.name = "headplane";

    roles.server.machines.agentc = { };
  };

  clan.modules.headplane = {
    _class = "clan.service";
    manifest = {
      name = "headplane";
      readme = "Headplane is a web UI for managing a Headscale server.";
      exports.out = [ "route" ];
    };

    roles = {
      server = {
        description = "Runs the Headplane web UI.";
        perInstance =
          { mkExports, machine, ... }:
          let
            subdomain = "headplane";
            port = 3001;
          in
          {
            exports = mkExports {
              route = {
                inherit subdomain port;
                machineName = machine.name;
              };
            };

            nixosModule =
              {
                config,
                pkgs,
                lib,
                ...
              }:
              let
                format = pkgs.formats.yaml { };

                # Workaround: headplane requires a valid headscale config file with
                # tls_cert_path, tls_key_path, and policy.path set to something.
                headscaleSettings = lib.recursiveUpdate config.services.headscale.settings {
                  tls_cert_path = "/dev/null";
                  tls_key_path = "/dev/null";
                  policy.path = "/dev/null";
                };

                headscaleConfig = format.generate "headscale.yml" headscaleSettings;
              in
              {
                disabledModules = [ "services/networking/headplane.nix" ];
                imports = [
                  inputs.headplane.nixosModules.headplane
                  {
                    nixpkgs.overlays = [ inputs.headplane.overlays.default ];
                  }
                ];

                clan.core.vars.generators."headplane-cookie-secret" = {
                  files.secret = {
                    secret = true;
                    owner = config.services.headscale.user;
                    mode = "0400";
                  };
                  runtimeInputs = [
                    pkgs.coreutils
                    pkgs.openssl
                  ];
                  script = ''
                    openssl rand -hex 16 > $out/secret
                  '';
                };

                clan.core.vars.generators."headplane-api-key" = {
                  prompts.api-key = {
                    description = "Headscale API key for Headplane (create with: headscale apikeys create)";
                    type = "hidden";
                  };
                  files.secret = {
                    secret = true;
                    owner = config.services.headscale.user;
                    mode = "0400";
                  };
                  runtimeInputs = [ pkgs.coreutils ];
                  script = ''
                    cat $prompts/api-key > $out/secret
                  '';
                };

                clan.core.vars.generators."headplane-oidc" = {
                  prompts.client-secret = {
                    description = "OpenID Connect Client Secret for Headplane (from Pocket-ID)";
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

                services.headplane = {
                  enable = true;
                  settings = {
                    server = {
                      host = config.networking.primaryIp;
                      inherit port;
                      cookie_secret_path = config.clan.core.vars.generators."headplane-cookie-secret".files.secret.path;
                      base_url = "https://${subdomain}.${config.clan.core.settings.domain}";
                    };
                    headscale = {
                      url = "https://headscale.${config.clan.core.settings.domain}";
                      config_path = "${headscaleConfig}";
                      api_key_path = config.clan.core.vars.generators."headplane-api-key".files.secret.path;
                    };
                    integration.agent = {
                      enabled = true;
                    };
                    oidc = {
                      issuer = "https://pocket-id.${config.clan.core.settings.domain}";
                      client_id = "a38a5662-323e-47a5-bd47-844a8c7440a2";
                      client_secret_path = config.clan.core.vars.generators."headplane-oidc".files.secret.path;
                      disable_api_key_login = true;
                    };
                  };
                };

                preservation.preserveAt."/persist".directories = [
                  {
                    directory = "/var/lib/headplane";
                    user = config.services.headscale.user;
                    group = config.services.headscale.group;
                    mode = "0750";
                  }
                ];
              };
          };
      };
    };
  };
}
