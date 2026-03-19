{ inputs, ... }:
{
  flake.aspects.darwin = {
    base = {
      system.stateVersion = 5;
      nix.enable = false;
      system = {
        defaults.dock = {
          autohide = true;
          mru-spaces = false;
          show-recents = false;
        };
        defaults.finder = {
          AppleShowAllExtensions = true;
          ShowPathbar = true;
          FXDefaultSearchScope = "SCcf";
        };
        defaults.trackpad = {
          Clicking = true;
          TrackpadCornerSecondaryClick = 2;
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
