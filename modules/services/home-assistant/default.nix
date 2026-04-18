_: {

  clan.inventory.instances.home-assistant = {
    module.input = "self";
    module.name = "home-assistant";

    roles.server.machines.agentc = { };
  };

  clan.modules.home-assistant = {
    _class = "clan.service";
    manifest = {
      name = "home-assistant";
      readme = "Home Assistant is an open-source home automation platform focused on privacy and local control.";
      exports.out = [ "route" ];
    };

    roles = {
      server = {
        description = "Runs the Home Assistant server.";
        perInstance =
          { mkExports, machine, ... }:
          let
            subdomain = "home";
            port = 8123;
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
                ...
              }:
              let
                cfg = config.services.home-assistant;
              in
              {
                services.home-assistant = {
                  enable = true;
                  extraComponents = [
                    "default_config"
                    "met"
                    "esphome"
                    "roborock"
                    "hue"
                  ];
                  config = {
                    http = {
                      use_x_forwarded_for = true;
                      # FIXME: Avoid split-brain config by deriving this from the reverse-proxy server role/export
                      # instead of pinning static values here.
                      trusted_proxies = [
                        "127.0.0.1"
                        "::1"
                        "192.168.1.3"
                      ];
                    };
                  };
                };

                environment.persistence."/persist".directories = [
                  {
                    directory = cfg.configDir;
                    user = "hass";
                    group = "hass";
                    mode = "0750";
                  }
                ];
              };
          };
      };
    };
  };
}
