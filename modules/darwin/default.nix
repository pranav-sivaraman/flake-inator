{
  flake.aspects.darwin = {
    base = {
      system.stateVersion = 5;
      nix.enable = false;
      system = {
        defaults = {
          screencapture.target = "clipboard";
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

    };

    homebrew = {
      homebrew = {
        enable = true;
        casks = [
          "flux-app"
          "yubico-authenticator"
          "google-chrome"
        ];
        onActivation = {
          cleanup = "uninstall";
          autoUpdate = true;
          upgrade = true;
        };
      };
    };
  };
}
