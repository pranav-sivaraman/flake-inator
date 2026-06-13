{
  flake.aspects.shell = {
    homeManager = {
      programs.nvf.settings.vim = {
        globals.maplocalleader = " ";
        preventJunkFiles = true;
        undoFile.enable = true;
        options = {
          relativenumber = true;
          expandtab = true;
          tabstop = 2;
          shiftwidth = 2;
          smartindent = true;
          shada = "!,'100,<50,s10,h";
          foldlevel = 99;
          foldlevelstart = 99;
        };
      };
    };
  };
}
