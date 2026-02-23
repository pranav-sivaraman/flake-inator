{ inputs, ... }:
{
  flake.aspects.shell = {
    homeManager = {
      programs.nvf.settings.vim = {
        utility.yanky-nvim = {
          enable = true;
        };

        keymaps = [
          {
            mode = [
              "n"
              "x"
            ];
            key = "p";
            action = "<Plug>(YankyPutAfter)";
            desc = "Put yanked text after cursor";
          }
          {
            mode = [
              "n"
              "x"
            ];
            key = "P";
            action = "<Plug>(YankyPutBefore)";
            desc = "Put yanked text before cursor";
          }
          {
            mode = [
              "n"
              "x"
            ];
            key = "gp";
            action = "<Plug>(YankyGPutAfter)";
            desc = "Put yanked text after selection";
          }
          {
            mode = [
              "n"
              "x"
            ];
            key = "gP";
            action = "<Plug>(YankyGPutBefore)";
            desc = "Put yanked text before selection";
          }
          {
            mode = "n";
            key = "<c-p>";
            action = "<Plug>(YankyPreviousEntry)";
            desc = "Select previous yank from history";
          }
          {
            mode = "n";
            key = "<c-n>";
            action = "<Plug>(YankyNextEntry)";
            desc = "Select next yank from history";
          }
        ];

        luaConfigRC.osc52-clipboard = inputs.nvf.lib.nvim.dag.entryAnywhere ''
          local g = vim.g
          local o = vim.o

          o.clipboard = "unnamedplus"
          g.clipboard = {
            name = "OSC 52",
            copy = {
              ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
              ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
            },
            paste = {
              ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
              ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
            },
          }
        '';
      };
    };
  };
}
