{ inputs, ... }:
{

  flake-file.inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
  };

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
          package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi;
          configDir = "${config.xdg.configHome}/pi/agent";
          settings = {
            packages = [
              "npm:@earendil-works/pi-voice"
            ];
          };
          extraPackages = with pkgs; [
            ffmpeg
          ];
        };
      };
    };
}
