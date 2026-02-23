{ inputs, ... }:
{
  flake.aspects.shell = {
    homeManager =
      { pkgs, ... }:
      {
        programs.nvf.settings.vim = {
          mini = {
            ai.enable = true;
            animate.enable = true;
            pairs.enable = true;
            basics = {
              enable = true;
              setupOpts = {
                options.extra_ui = true;
                mappings.windows = false;
                autocmds.enable = false;
              };
            };
          };

          startPlugins = [ pkgs.vimPlugins.mini-nvim ];
          luaConfigRC.mini-keymap = inputs.nvf.lib.nvim.dag.entryAnywhere ''
            require("mini.keymap").setup()
            local map_combo = require("mini.keymap").map_combo
            local mode = { "i", "c", "x", "s" }
            map_combo(mode, "jk", "<BS><BS><Esc>")
            map_combo("t", "jk", "<BS><BS><C-\\><C-n>")
          '';
        };
      };
  };
}
