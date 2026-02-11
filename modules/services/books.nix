{ inputs, ... }:
{

  clan.inventory.instances.booklore = {
    module.input = "self";
    module.name = "booklore";

    roles.server.machines.agentc = { };
  };

  clan.modules.booklore =
    { clanLib, lib, ... }:
    {
      _class = "clan.service";
      manifest.name = "booklore";
      manifest.readme = "BookLore is a self-hosted service to manage and explore books, with support for PDFs, eBooks, reading progress, metadata, and stats.";

      roles = {
        server = {
          description = "Runs the BookLore server.";
          perInstance =
            { mkExports, ... }:
            let
              subdomain = "books";
              port = 8080;
            in
            {
              exports = mkExports {
                storage = {
                  exports = [
                    {
                      path = "/persist/var/lib/booklore/data";
                      mountPoint = "/var/lib/booklore/data";
                    }
                  ];
                  user = "booklore";
                  group = "booklore";
                  readOnly = false;
                };
                route = {
                  subdomain = subdomain;
                  interface = "localhost";
                  port = "8080";
                };
              };

              nixosModule =
                { config, pkgs, ... }:
                {
                  imports = [
                    "${inputs.nixpkgs-booklore}/nixos/modules/services/web-apps/booklore.nix"
                  ];

                  nixpkgs.overlays = [
                    (final: prev: {
                      booklore =
                        (import inputs.nixpkgs-booklore {
                          inherit (prev) system;
                          config.allowUnfree = true;
                        }).booklore;
                    })
                  ];

                  clan.core.vars.generators."booklore-environmentFile" = {
                    files.env = {
                      secret = true;
                      owner = "booklore";
                      mode = "0400";
                    };
                    runtimeInputs = [
                      pkgs.coreutils
                      pkgs.xkcdpass
                    ];
                    script = ''
                      db_password=$(xkcdpass -n 6 -d -)
                      cat > $out/env <<EOF
                      DATABASE_PASSWORD=$db_password
                      EOF
                    '';
                  };

                  services.booklore = {
                    enable = true;
                    port = port;
                    database.createLocally = true;
                    environmentFile = config.clan.core.vars.generators.booklore-environmentFile.files.env.path;
                  };

                  environment.persistence."/persist".directories = [
                    {
                      directory = "/var/lib/mysql";
                      user = "mysql";
                      group = "mysql";
                      mode = "0700";
                    }
                  ];
                };
            };
        };
      };
    };
}
