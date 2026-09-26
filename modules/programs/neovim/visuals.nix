{ inputs, ... }:
{
  flake.modules.homeManager.default = {
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
        rainbow-delimiters.enable = true;
        nvim-web-devicons.enable = true;

        indent-blankline = {
          enable = true;
          setupOpts.scope.highlight = [
            "RainbowDelimiterRed"
            "RainbowDelimiterYellow"
            "RainbowDelimiterBlue"
            "RainbowDelimiterOrange"
            "RainbowDelimiterGreen"
            "RainbowDelimiterViolet"
            "RainbowDelimiterCyan"
          ];
        };
      };

      # Register the rainbow-delimiters/IBL integration after nvf lazy-loads
      # and configures IBL. This is the same integration used by AstroNvim.
      lazy.plugins.indent-blankline-nvim.after = ''
        local hooks = require("ibl.hooks")
        hooks.register(
          hooks.type.SCOPE_HIGHLIGHT,
          hooks.builtin.scope_highlight_from_extmark
        )
      '';
    };
  };
}
