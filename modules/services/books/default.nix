_: {

  clan.inventory.instances.kavita = {
    module.input = "self";
    module.name = "kavita";

    roles.server.machines.agentc = { };
  };

  clan.modules.kavita = {
    _class = "clan.service";
    manifest = {
      name = "kavita";
      readme = "Kavita is a self-hosted digital library for managing and reading comics, manga, and books.";
      exports.out = [ "route" ];
    };

    roles = {
      server = {
        description = "Runs the Kavita server.";
        perInstance =
          { mkExports, ... }:
          let
            subdomain = "books";
          in
          {
            exports = mkExports {
              route = {
                subdomain = subdomain;
                interface = "localhost";
                port = "5000";
              };
            };

            nixosModule =
              { config, pkgs, ... }:
              let
                cfg = config.services.kavita;
              in
              {
                clan.core.vars.generators."kavita-tokenKeyFile" = {
                  files.tokenKey = {
                    secret = true;
                    owner = cfg.user;
                    mode = "0400";
                  };
                  runtimeInputs = [
                    pkgs.coreutils
                  ];
                  script = ''
                    head -c 64 /dev/urandom | base64 --wrap=0 > $out/tokenKey
                  '';
                };

                services.kavita = {
                  enable = true;
                  tokenKeyFile = config.clan.core.vars.generators.kavita-tokenKeyFile.files.tokenKey.path;
                  settings = {
                    IpAddresses = "localhost";
                  };
                };

                environment.persistence."/persist".directories = [
                  {
                    directory = cfg.dataDir;
                    inherit (cfg) user;
                    group = cfg.user;
                    mode = "0750";
                  }
                ];
              };
          };
      };
    };
  };
}
