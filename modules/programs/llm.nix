{
  flake.modules.homeManager.default =
    { config, ... }:
    {
      home = {
        sessionVariables = {
          PI_OFFLINE = "1";
        };
      };

      programs = {
        pi-coding-agent = {
          enable = true;
          configDir = "${config.xdg.configHome}/pi/agent";
        };
      };
    };
}
