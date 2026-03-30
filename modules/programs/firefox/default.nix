{ inputs, ... }:
let
  firefox-addons = system: inputs.nur.legacyPackages.${system}.repos.rycee.firefox-addons;
in
{
  flake.aspects.desktop = {
    homeManager =
      { pkgs, ... }:
      let
        addons = firefox-addons pkgs.stdenv.hostPlatform.system;
      in
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
          };

          profiles.default = {
            extensions.packages = with addons; [
              ublock-origin
              sponsorblock
              bitwarden
              bypass-paywalls-clean
              refined-github
              web-clipper-obsidian
              reddit-enhancement-suite
              zotero-connector
              darkreader
            ];

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
