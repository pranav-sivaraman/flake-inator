{
  flake.aspects.ssh = {
    homeManager =
      { lib, pkgs, ... }:
      let
        skLib = "sk-libfido2${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}";

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

        pkgs' = pkgs.extend (
          final: prev: {
            openssh = prev.openssh.overrideAttrs (oldAttrs: {
              configureFlags = (oldAttrs.configureFlags or [ ]) ++ [
                "--with-security-key-standalone"
              ];
              postInstall = (oldAttrs.postInstall or "") + ''
                mkdir -p "$out/lib"
                cp ${skLib} "$out/lib"
              '';
            });
          }
        );
      in
      lib.mkMerge [
        {
          home.packages = [ pkgs'.openssh ] ++ lib.optionals pkgs.stdenv.isDarwin [ ssh-askpass-mac ];

          programs.ssh = {
            enable = true;
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
                # ForwardX11 = true;
                # ForwardX11Trusted = true;
                ServerAliveCountMax = 15;
                ServerAliveInterval = 15;
                SetEnv = {
                  TERM = "xterm-256color";
                };
                SecurityKeyProvider = "${pkgs'.openssh}/lib/${skLib}";
              };
            };
          };

          services.ssh-agent = {
            enable = true;
            package = pkgs'.openssh;
            pkcs11Whitelist = [ "${pkgs'.openssh}/lib/${skLib}" ];
          };

        }
        (lib.mkIf pkgs.stdenv.isDarwin {
          launchd.agents.ssh-agent.config.EnvironmentVariables = {
            SSH_SK_PROVIDER = "${pkgs'.openssh}/lib/${skLib}";
            SSH_ASKPASS = "${ssh-askpass-mac}/bin/ssh-askpass";
            SSH_ASKPASS_REQUIRE = "prefer";
            DISPLAY = ":0";
          };
        })
      ];
  };
}
