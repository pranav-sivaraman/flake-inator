{
  flake.modules.homeManager.default = {
    programs.nvf.settings.vim = {
      theme = {
        enable = true;
        name = "rose-pine";
        style = "main";
      };
    };
  };
}
