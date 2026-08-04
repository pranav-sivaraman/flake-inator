{
  flake.modules.homeManager.default = {
    programs.nvf.settings.vim = {
      viAlias = true;
      vimAlias = true;

      binds.whichKey.enable = true;
    };
  };
}
