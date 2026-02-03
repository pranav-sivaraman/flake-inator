{
  clan.inventory.instances.oidc = {
    module.input = "self";
    module.name = "oidc";

    roles.server.machines.agentc = { };
  };

  clan.modules.oidc = {
    _class = "clan.service";
    manifest.name = "oidc";

    roles = {
      server = {
        perInstance =
          { mkExports, ... }:
          let
            subdomain = "pocket-id";
          in
          {
            exports = mkExports {
              route = {
                subdomain = subdomain;
                interface = "localhost"; # TODO: switch to DNS name?
                port = "1411";
              };
            };

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
                    APP_URL = "https://${subdomain}.${config.clan.core.settings.domain}";
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
              };
          };
      };
    };
  };
}
