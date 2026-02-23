{ inputs, ... }:
{
  flake.aspects.shell = {
    homeManager = {
      programs.bat = {
        enable = true;
        config = {
          theme = "rose-pine";
          style = "plain";
          pager = "never";
        };
        themes = {
          rose-pine = {
            src = inputs.rose-pine-tmtheme;
            file = "dist/rose-pine.tmTheme";
          };
          rose-pine-moon = {
            src = inputs.rose-pine-tmtheme;
            file = "dist/rose-pine-moon.tmTheme";
          };
          rose-pine-dawn = {
            src = inputs.rose-pine-tmtheme;
            file = "dist/rose-pine-dawn.tmTheme";
          };
        };
      };

      home.shellAliases = {
        cat = "bat";
      };
    };
  };
}
