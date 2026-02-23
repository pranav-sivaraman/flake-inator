{ inputs, ... }:
{
  flake.aspects.shell = {
    homeManager = {
      programs.nvf.settings.vim = {
        ui.noice = {
          enable = true;
          setupOpts = {
            cmdline = {
              view = "cmdline";
            };
            presets = {
              bottom_search = true;
              command_palette = false;
              long_message_to_split = true;
              inc_rename = false;
              lsp_doc_border = false;
            };
          };
        };

        visuals = {
          fidget-nvim.enable = true;
          cellular-automaton.enable = true;
          syntax-gaslighting.enable = true;
          rainbow-delimiters.enable = true;
          nvim-web-devicons.enable = true;

          indent-blankline = {
            enable = true;
            setupOpts.scope.highlight = [
              "RainbowRed"
              "RainbowYellow"
              "RainbowBlue"
              "RainbowOrange"
              "RainbowGreen"
              "RainbowViolet"
              "RainbowCyan"
            ];
          };
        };

        luaConfigRC.rainbow-delimiters-integration =
          inputs.nvf.lib.nvim.dag.entryBefore [ "pluginConfigs" ]
            ''
              local rainbow_colors = {
                { name = "RainbowRed", color = "#E06C75" },
                { name = "RainbowYellow", color = "#E5C07B" },
                { name = "RainbowBlue", color = "#61AFEF" },
                { name = "RainbowOrange", color = "#D19A66" },
                { name = "RainbowGreen", color = "#98C379" },
                { name = "RainbowViolet", color = "#C678DD" },
                { name = "RainbowCyan", color = "#56B6C2" },
              }

              local highlight = {}
              for _, hl in ipairs(rainbow_colors) do
                table.insert(highlight, hl.name)
              end

              local hooks = require "ibl.hooks"
              -- Create highlight groups before indent-blankline setup and reset on colorscheme change
              hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                for _, hl in ipairs(rainbow_colors) do
                  vim.api.nvim_set_hl(0, hl.name, { fg = hl.color })
                end
              end)

              vim.g.rainbow_delimiters = { highlight = highlight }
              hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
            '';
      };
    };
  };
}
