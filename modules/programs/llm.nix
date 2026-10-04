{
  flake.modules.homeManager.default =
    { config, pkgs, ... }:
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
          settings = {
            packages = [
              "npm:@earendil-works/pi-voice"
            ];
          };
          extraPackages = with pkgs; [
            nodejs
            ffmpeg
          ];
        };
      };
    };
}
