{
  flake.modules.homeManager.default =
    { lib, pkgs, ... }:
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

          servers.mojo = {
            enable = true;
            cmd = [ (lib.getExe' pkgs.mojo-bin "mojo-lsp-server") ];
            filetypes = [ "mojo" ];
            root_markers = [ ".git" ];
          };
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
}
