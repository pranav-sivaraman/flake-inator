{ inputs, ... }:
{
  flake.aspects.shell = {
    homeManager = {
      programs.btop = {
        enable = true;
        settings = {
          color_theme = "rose-pine";
          theme_background = false;
        };
      };

      xdg.configFile."btop/themes/rose-pine.theme".source = "${inputs.rose-pine-btop}/rose-pine.theme";
    };
  };
}
