{ inputs, ... }:
{
  flake.aspects.darwin = {
    base = {
      system.stateVersion = 5;
      nix.enable = false;
      system = {
        defaults = {
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
        ];
        onActivation = {
          cleanup = "zap";
          autoUpdate = true;
          upgrade = true;
        };
      };
    };

    home-manager = {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.psivaram.imports = inputs.self.homeManagerModules.full;
      };
    };
  };
}
