{

  clan.inventory.instances.paperless-ngx = {
    module.input = "self";
    module.name = "paperless-ngx";

    roles.server.machines.agentc = { };
  };
  clan.modules.paperless-ngx =
    { clanLib, lib, ... }:
    {
      _class = "clan.service";
      manifest.name = "paperless-ngx";
      manifest.readme = "A community-supported open-source document management system that transforms your physical documents into a searchable online archive so you can keep, well, less paper.";

      roles = {
        server = {
          description = "Runs the paperless-ngx server.";
          perInstance =
            {
              mkExports,
              ...
            }:
            let
              subdomain = "pdfs";
            in
            {
              exports = mkExports {
                storage =
                  let
                    baseServerPath = "/persist/var/lib/paperless";
                    baseClientPath = "/var/lib/paperless";
                    dirs = [
                      "media"
                      "consume"
                    ];
                  in
                  {
                    exports = map (dir: {
                      path = "${baseServerPath}/${dir}";
                      mountPoint = "${baseClientPath}/${dir}";
                    }) dirs;
                    user = "paperless";
                    group = "paperless";
                    readOnly = false;
                  };
                route = {
                  subdomain = subdomain;
                  interface = "localhost";
                  port = "28981";
                };
              };

              nixosModule =
                {
                  config,
                  pkgs,
                  ...
                }:
                {

                  clan.core.vars.generators = {
                    "paperless-env" = {
                      prompts.client-id = {
                        description = "OpenID Connect Client ID for Paperless-ngx";
                        type = "line";
                      };
                      prompts.client-secret = {
                        description = "OpenID Connect Client Secret for Paperless-ngx";
                        type = "hidden";
                      };
                      files.env = {
                        secret = true;
                        owner = "root";
                        mode = "0400";
                      };
                      runtimeInputs = [
                        pkgs.coreutils
                        pkgs.openssl
                        pkgs.jq
                      ];
                      # TODO: maybe have a way to query the oidc service for the url
                      script = ''
                        client_id=$(cat $prompts/client-id)
                        client_secret=$(cat $prompts/client-secret)

                        # Generate secret key
                        secret_key=$(openssl rand -base64 32)

                        # Generate OIDC JSON config (compact, single line)
                        oidc_config=$(jq -c -n \
                          --arg client_id "$client_id" \
                          --arg client_secret "$client_secret" \
                          --arg server_url "https://pocket-id.${config.clan.core.settings.domain}" \
                          '{
                            "openid_connect": {
                              "SCOPE": ["openid", "profile", "email"],
                              "OAUTH_PKCE_ENABLED": true,
                              "APPS": [{
                                "provider_id": "pocket-id",
                                "name": "Pocket-ID",
                                "client_id": $client_id,
                                "secret": $client_secret,
                                "settings": {
                                  "server_url": $server_url
                                }
                              }]
                            }
                          }')

                        # Write environment file
                        cat > $out/env <<EOF
                        PAPERLESS_SECRET_KEY=$secret_key
                        PAPERLESS_SOCIALACCOUNT_PROVIDERS=$oidc_config
                        EOF
                      '';
                    };
                  };
                  services.paperless = {
                    enable = true;
                    domain = "${subdomain}.${config.clan.core.settings.domain}";
                    database.createLocally = true;
                    configureTika = true;
                    settings = {
                      PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
                      PAPERLESS_DISABLE_REGULAR_LOGIN = "True";
                      PAPERLESS_REDIRECT_LOGIN_TO_SSO = "True";
                    };
                  };

                  systemd.services = {
                    paperless-scheduler.serviceConfig.EnvironmentFile =
                      config.clan.core.vars.generators.paperless-env.files.env.path;
                    paperless-web.serviceConfig.EnvironmentFile =
                      config.clan.core.vars.generators.paperless-env.files.env.path;
                  };

                  environment.persistence."/persist".directories = [
                    {
                      directory = "/var/lib/redis-paperless";
                      user = "redis-paperless";
                      group = "redis-paperless";
                      mode = "0700";
                    }
                  ];
                };
            };
        };
      };
    };
}
