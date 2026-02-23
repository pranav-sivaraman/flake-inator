{
  flake.aspects.shell = {
    homeManager = {
      programs.nvf.settings.vim = {
        preventJunkFiles = true;
        undoFile.enable = true;
        options = {
          expandtab = true;
          tabstop = 2;
          shiftwidth = 2;
          smartindent = true;
          shada = "!,'100,<50,s10,h";
        };
      };
    };
  };
}
