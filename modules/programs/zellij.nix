{ inputs, ... }:
let
  pluginPath = "file:${inputs.vim-zellij-navigator}";
in
{
  flake-file.inputs = {
    vim-zellij-navigator = {
      # TODO: change this to git? or built in packages
      url = "https://github.com/hiasr/vim-zellij-navigator/releases/latest/download/vim-zellij-navigator.wasm";
      flake = false;
    };
    rose-pine-zellij = {
      url = "github:rose-pine/zellij";
      flake = false;
    };
  };
  flake.modules.homeManager.default = {
    programs.zellij = {
      enable = true;
      settings = {
        show_startup_tips = false;
        theme = "rose-pine";
      };
      extraConfig = ''
        keybinds {
          shared_except "locked" {
            bind "Ctrl h" {
              MessagePlugin "${pluginPath}" {
                name "move_focus";
                payload "left";
              };
            }
            bind "Ctrl j" {
              MessagePlugin "${pluginPath}" {
                name "move_focus";
                payload "down";
              };
            }
            bind "Ctrl k" {
              MessagePlugin "${pluginPath}" {
                name "move_focus";
                payload "up";
              };
            }
            bind "Ctrl l" {
              MessagePlugin "${pluginPath}" {
                name "move_focus";
                payload "right";
              };
            }
            bind "Alt h" {
              MessagePlugin "${pluginPath}" {
                name "resize";
                payload "left";
              };
            }
            bind "Alt j" {
              MessagePlugin "${pluginPath}" {
                name "resize";
                payload "down";
              };
            }
            bind "Alt k" {
              MessagePlugin "${pluginPath}" {
                name "resize";
                payload "up";
              };
            }
            bind "Alt l" {
              MessagePlugin "${pluginPath}" {
                name "resize";
                payload "right";
              };
            }
          }
        }
      '';
    };
    xdg.configFile."zellij/themes/rose-pine.kdl".source =
      "${inputs.rose-pine-zellij}/dist/rose-pine.kdl";
  };
}
