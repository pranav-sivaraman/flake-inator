{
  clan.inventory.instances.seerr = {
    module.input = "self";
    module.name = "seerr";

    roles.server.machines.agentc = { };
  };

  clan.modules.seerr = {
    _class = "clan.service";
    manifest = {
      name = "seerr";
      readme = "Seerr is a requests manager for Jellyfin.";
      exports.out = [ "route" ];
    };

    roles = {
      server = {
        description = "Runs the Seerr request manager.";
        perInstance =
          { mkExports, machine, ... }:
          let
            subdomain = "seerr";
            port = 5055;
          in
          {
            exports = mkExports {
              route = {
                inherit subdomain port;
                machineName = machine.name;
              };
            };

            nixosModule = {
              services.seerr = {
                enable = true;
                inherit port;
              };

              environment.persistence."/persist".directories = [
                {
                  directory = "/var/lib/private/seerr";
                  user = "root";
                  group = "root";
                  mode = "0700";
                }
              ];
            };
          };
      };
    };
  };
}
