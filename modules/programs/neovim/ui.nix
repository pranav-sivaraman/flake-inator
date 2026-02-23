{
  flake.aspects.shell = {
    homeManager = {
      programs.nvf.settings.vim = {
        viAlias = true;
        vimAlias = true;

        binds.whichKey.enable = true;
      };
    };
  };
}
