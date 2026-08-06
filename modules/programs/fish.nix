{ inputs, lib, ... }:
{
  flake-file.inputs.rose-pine-fish = {
    url = "github:rose-pine/fish";
    flake = false;
  };

  flake.modules.homeManager.default =
    _:
    let
      themes = [
        "Rosé Pine"
        "Rosé Pine Moon"
        "Rosé Pine Dawn"
      ];

      themeFiles = lib.listToAttrs (
        map (theme: {
          name = "fish/themes/${theme}.theme";
          value.source = "${inputs.rose-pine-fish}/themes/${theme}.theme";
        }) themes
      );
    in
    {
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          fish_config theme choose "Rosé Pine"
        '';
        functions = {
          ndf = {
            description = "Run nix develop using fish";
            body = ''
              nix develop $argv --command fish
            '';
          };
        };
      };
      xdg.configFile = themeFiles;
    };
}
