_: {
  clan.inventory.instances.finance = {
    module.input = "self";
    module.name = "finance";

    roles.server.machines.agentc = { };
  };

  clan.modules.finance = {
    _class = "clan.service";
    manifest = {
      name = "finance";
      readme = "Actual Budget is a self-hosted personal finance app for tracking accounts, budgets, and spending.";
      exports.out = [ "route" ];
    };

    roles = {
      server = {
        description = "Runs the Actual Budget server.";
        perInstance =
          { mkExports, machine, ... }:
          let
            subdomain = "finance";
            port = 3000;
          in
          {
            exports = mkExports {
              route = {
                inherit subdomain port;
                machineName = machine.name;
              };
            };

            nixosModule =
              { config, ... }:
              {
                services.actual = {
                  enable = true;
                  settings = {
                    hostname = config.networking.primaryIp;
                    inherit port;
                  };
                };

                environment.persistence."/persist".directories = [
                  "/var/lib/private/actual"
                ];

              };
          };
      };
    };
  };
}
