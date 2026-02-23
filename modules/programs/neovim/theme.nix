{
  flake.aspects.shell = {
    homeManager = {
      programs.nvf.settings.vim = {
        theme = {
          enable = true;
          name = "rose-pine";
          style = "main";
        };
      };
    };
  };
}
