{ inputs, ... }:
{
  flake-file.inputs.rose-pine-btop = {
    url = "github:rose-pine/btop";
    flake = false;
  };

  flake.modules.homeManager.default = {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "rose-pine";
        theme_background = false;
      };
    };
    xdg.configFile."btop/themes/rose-pine.theme".source = "${inputs.rose-pine-btop}/rose-pine.theme";
  };
}
