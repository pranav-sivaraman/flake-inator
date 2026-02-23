{
  flake.aspects.shell = {
    homeManager =
      { pkgs, ... }:
      let
        skLib = "sk-libfido2${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}";

        # macOS-native SSH askpass based on https://github.com/theseal/ssh-askpass
        ssh-askpass-mac = pkgs.writeScriptBin "ssh-askpass" ''
          #!${pkgs.stdenv.shell}
          exec /usr/bin/osascript - "$@" <<'APPLESCRIPT'
          on run argv
              set args to argv as text
              considering numeric strings
                  set pre_catalina to (system version of (system info)) < "10.15"
              end considering
              if pre_catalina then
                  set agent to POSIX file "/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns"
              else
                  set agent to POSIX file "/System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns"
              end if
              set dialog_timeout to 15

              set prompt to system attribute "SSH_ASKPASS_PROMPT"
              # prompt = "confirm" is the same as our else, so just let it pass though
              if prompt is "none" then
                  display dialog args with icon agent default button 1 buttons { "OK" }
              else if args ends with ": " or args ends with ":" then
                  if args contains "pass" or args contains "pin" then
                      display dialog args with icon agent default button 2 default answer "" with hidden answer
                  else
                      display dialog args with icon agent default button 2 default answer ""
                  end if
                  return result's text returned
              else if args contains " host " then
                  display dialog args with icon agent default button 1 cancel button 2 buttons {"OK", "No", "Yes"} default answer ""
                  set host_key_result to result
                  if text returned of host_key_result is not "" then
                      return text returned of host_key_result
                  else
                      return button returned of host_key_result
                  end if
              else
                  display dialog args with icon agent default button 1 giving up after dialog_timeout
                  if gave up of result then
                      error result
                  end if
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
      {
        home.packages = with pkgs'; [
          openssh
          ssh-askpass-mac
        ];

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          matchBlocks = {
            "github.com" = {
              user = "git";
            };
            "*" = {
              compression = true;
              controlMaster = "auto";
              controlPath = "/tmp/%r@%h:%p";
              controlPersist = "yes";
              forwardAgent = true;
              # forwardX11 = true;
              # forwardX11Trusted = true;
              serverAliveCountMax = 15;
              serverAliveInterval = 15;
              setEnv = {
                TERM = "xterm-256color";
              };
              extraOptions = {
                SecurityKeyProvider = "${pkgs'.openssh}/lib/${skLib}";
              };
            };
          };
        };

        services.ssh-agent = {
          enable = true;
          package = pkgs'.openssh;
          pkcs11Whitelist = [ "${pkgs'.openssh}/lib/${skLib}" ];
        };

        launchd.agents.ssh-agent.config.EnvironmentVariables = {
          SSH_SK_PROVIDER = "${pkgs'.openssh}/lib/${skLib}";
          SSH_ASKPASS = "${ssh-askpass-mac}/bin/ssh-askpass";
          SSH_ASKPASS_REQUIRE = "prefer";
          DISPLAY = ":0";
        };
      };
  };
}
