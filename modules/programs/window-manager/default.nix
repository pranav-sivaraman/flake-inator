{
  flake.aspects.window-manager = {
    homeManager =
      { lib, pkgs, ... }:
      lib.mkIf pkgs.stdenv.isDarwin {
        programs.aerospace = {
          enable = true;
          launchd.enable = true;
          settings = {
            mode.main.binding = {
              "cmd-1" = "workspace 1";
              "cmd-2" = "workspace 2";
              "cmd-3" = "workspace 3";
              "cmd-4" = "workspace 4";
              "cmd-5" = "workspace 5";
              "cmd-6" = "workspace 6";
              "cmd-7" = "workspace 7";
            };
            on-window-detected = [
              {
                "if".app-id = "com.mitchellh.ghostty";
                run = "move-node-to-workspace 1";
              }
              {
                "if".app-id = "org.nixos.firefox";
                run = "move-node-to-workspace 2";
              }
              {
                "if".app-id = "com.tinyspeck.slackmacgap";
                run = "move-node-to-workspace 3";
              }
              {
                "if".app-id = "md.obsidian";
                run = "move-node-to-workspace 4";
              }
              {
                "if".app-id = "com.hnc.Discord";
                run = "move-node-to-workspace 5";
              }
              {
                "if".app-id = "com.microsoft.teams2";
                run = "move-node-to-workspace 6";
              }
              {
                "if".app-id = "com.microsoft.Outlook";
                run = "move-node-to-workspace 7";
              }
            ];
          };
        };
      };
  };
}
