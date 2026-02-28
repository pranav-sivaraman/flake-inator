{ inputs, ... }:
{
  flake.aspects.desktop = {
    homeManager =
      { pkgs, ... }:
      {
        programs.firefox = {
          enable = true;

          policies = {
            # Updates & Background Services
            AppAutoUpdate = false;
            BackgroundAppUpdate = false;

            # Feature Disabling
            DisableBuiltinPDFViewer = false;
            DisableFirefoxStudies = true;
            DisableFirefoxAccounts = true;
            DisableFirefoxScreenshots = true;
            DisableForgetButton = true;
            DisableMasterPasswordCreation = true;
            DisableProfileImport = true;
            DisableProfileRefresh = true;
            DisableSetDesktopBackground = true;
            DisablePocket = true;
            DisableTelemetry = true;
            DisableFormHistory = true;
            DisablePasswordReveal = true;

            # Access Restrictions
            BlockAboutConfig = false;
            BlockAboutProfiles = true;
            BlockAboutSupport = true;

            # UI and Behavior
            DisplayMenuBar = "never";
            DontCheckDefaultBrowser = true;
            HardwareAcceleration = true;
            OfferToSaveLogins = false;

            # Extensions
            ExtensionSettings = {
              "*".installation_mode = "blocked";

              "uBlock0@raymondhill.net" = {
                install_url = "file://${inputs.firefox-ublock-origin}";
                installation_mode = "force_installed";
              };

              "sponsorBlocker@ajay.app" = {
                install_url = "file://${inputs.firefox-sponsorblock}";
                installation_mode = "force_installed";
              };

              "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
                install_url = "file://${inputs.firefox-bitwarden}";
                installation_mode = "force_installed";
              };

              "magnolia@12.34" = {
                install_url = "file://${inputs.firefox-bypass-paywalls-clean}";
                installation_mode = "force_installed";
              };

              "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = {
                install_url = "file://${inputs.firefox-refined-github}";
                installation_mode = "force_installed";
              };

              "clipper@obsidian.md" = {
                install_url = "file://${inputs.firefox-obsidian-web-clipper}";
                installation_mode = "force_installed";
              };

              "jid1-xUfzOsOFlzSOXg@jetpack" = {
                install_url = "file://${inputs.firefox-reddit-enhancement-suite}";
                installation_mode = "force_installed";
              };

              "addon@darkreader.org" = {
                install_url = "file://${inputs.firefox-dark-reader}";
                installation_mode = "force_installed";
              };
            };
          };

          profiles.default = {
            search = {
              force = true;
              default = "google";
              privateDefault = "google";

              engines = {
                "Nix Packages" = {
                  urls = [
                    {
                      template = "https://searchix.ovh/packages/nixpkgs/search";
                      params = [
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@np" ];
                };

                "NixOS Options" = {
                  urls = [
                    {
                      template = "https://searchix.ovh/options/nixos/search";
                      params = [
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@no" ];
                };

                "Darwin Options" = {
                  urls = [
                    {
                      template = "https://searchix.ovh/options/darwin/search";
                      params = [
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@da" ];
                };

                "Home Manager Options" = {
                  urls = [
                    {
                      template = "https://searchix.ovh/options/home-manager/search";
                      params = [
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@hm" ];
                };

                "NixOS Wiki" = {
                  urls = [
                    {
                      template = "https://wiki.nixos.org/w/index.php";
                      params = [
                        {
                          name = "search";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@nw" ];
                };
              };
            };

            settings = {
              # Disabled: This setting can interfere with WebAuthn/FIDO2 (YubiKey) functionality
              # and potentially break OIDC flows that rely on hardware security keys.
              # "privacy.resistFingerprinting" = true;

              # Enable WebAuthn/Passkey support for YubiKey and platform authenticators
              "security.webauth.webauthn" = true;
              "security.webauth.webauthn_enable_softtoken" = true;
              "security.webauth.webauthn_enable_usbtoken" = true;
              "security.webauth.webauthn_enable_android_fido2" = true;
              "security.webauth.u2f" = true;

              # Enable macOS platform authenticator (Touch ID/Face ID)
              "security.webauthn.ctap2" = true;
              "security.webauthn.enable_macos_passkeys" = true;

              "browser.toolbars.bookmarks.visibility" = "always";
              "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
            };
          };
        };
      };
  };
}
