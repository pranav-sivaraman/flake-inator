{ inputs, lib, ... }:
{
  flake.aspects.shell = {
    homeManager =
      { ... }:
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
        };

        xdg.configFile = themeFiles;
      };
  };
}
