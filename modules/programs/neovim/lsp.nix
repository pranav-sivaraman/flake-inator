{
  flake.aspects.shell = {
    homeManager =
      { pkgs, ... }:
      {
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

          lazy.plugins = {
            "lean.nvim" = {
              package = pkgs.vimPlugins.lean-nvim;
              setupModule = "lean";
              setupOpts = {
                mappings = true;
              };
              event = [ "BufReadPre *.lean" ];
            };
          };
        };
      };
  };
}
