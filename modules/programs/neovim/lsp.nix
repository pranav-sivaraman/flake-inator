{
  flake.aspects.shell = {
    homeManager = {
      programs.nvf.settings.vim = {
        diagnostics = {
          enable = true;
          config.virtual_lines = true;
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          inlayHints.enable = true;
        };
      };
    };
  };
}
