{
  flake.modules.homeManager.default =
    { lib, pkgs, ... }:
    let
      ssh-askpass-mac = pkgs.writeShellScriptBin "ssh-askpass" ''
        exec /usr/bin/osascript - "$@" <<'APPLESCRIPT'
        on run argv
          set message to argv as text
          set prompt to system attribute "SSH_ASKPASS_PROMPT"

          if prompt is "none" then
            display dialog message buttons {"OK"} default button "OK" with title "SSH authentication"
          else if prompt is "confirm" then
            display dialog message buttons {"No", "Yes"} default button "Yes" cancel button "No" with title "SSH authentication"
          else
            display dialog message default answer "" with hidden answer with title "SSH authentication"
            return text returned of result
          end if
        end run
        APPLESCRIPT
      '';

    in
    lib.mkMerge [
      {
        home.packages = lib.optionals pkgs.stdenv.isDarwin [ ssh-askpass-mac ];

        programs.ssh = {
          enable = true;
          package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin pkgs.openssh;
          enableDefaultConfig = false;
          settings = {
            "github.com" = {
              User = "git";
            };
            "*" = {
              Compression = true;
              ControlMaster = "auto";
              ControlPath = "/tmp/%r@%h:%p";
              ControlPersist = "yes";
              ForwardAgent = true;
              ServerAliveCountMax = 15;
              ServerAliveInterval = 15;
              SetEnv = {
                TERM = "xterm-256color";
              };
            };
          };
        };

        services.ssh-agent = {
          enable = true;
        };

      }
      (lib.mkIf pkgs.stdenv.isDarwin {
        launchd.agents.ssh-agent.config.EnvironmentVariables = {
          SSH_ASKPASS = "${ssh-askpass-mac}/bin/ssh-askpass";
          SSH_ASKPASS_REQUIRE = "prefer";
          DISPLAY = ":0";
        };
      })
    ];
}
