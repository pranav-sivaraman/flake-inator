{ inputs, ... }:
{
  flake.darwinConfigurations = {
    Pranavs-MacBook-Air = inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = with inputs.self.aspects; [
        nix.darwin
        psivaram.darwin
        home-manager.darwin
        {
          system.stateVersion = 5;
          nix.enable = false;

          system = {
            defaults = {
              screencapture.target = "clipboard";
              NSGlobalDomain = {
                # Need to logout to apply this
                NSStatusItemSpacing = 10;
                NSStatusItemSelectionPadding = 6;
              };
              menuExtraClock = {
                ShowAMPM = true;
                ShowDayOfWeek = true;
                ShowDayOfMonth = true;
                ShowDate = 1;
              };
              controlcenter = {
                AirDrop = true;
                Sound = true;
                FocusModes = true;
                Display = true;
                NowPlaying = false;
                Bluetooth = true;
                BatteryShowPercentage = true;
              };
              dock = {
                autohide = true;
                mru-spaces = false;
                show-recents = false;
              };
              finder = {
                AppleShowAllExtensions = true;
                ShowPathbar = true;
                FXDefaultSearchScope = "SCcf";
              };
              trackpad = {
                Clicking = true;
                TrackpadCornerSecondaryClick = 2;
              };
            };
            keyboard = {
              enableKeyMapping = true;
              remapCapsLockToControl = true;
            };
          };

          homebrew = {
            enable = true;
            casks = [
              "flux-app"
              "yubico-authenticator"
              "google-chrome"
              "kobo"
              "calibre"
              "tailscale-app"
              "steam"
              "prismlauncher"
            ];
            onActivation = {
              cleanup = "uninstall";
              autoUpdate = true;
              upgrade = true;
              extraFlags = [
                "--force-cleanup"
              ];
            };
          };
        }
      ];
    };
  };
}
