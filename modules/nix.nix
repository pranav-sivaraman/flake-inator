let
  sharedNixConfig = { pkgs, config, ... }: {
    enable = !pkgs.stdenv.hostPlatform.isDarwin;
    channel.enable = false;
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    optimise.automatic = config.nix.enable;
    settings.experimental-features = [
      "nix-command"
      "flakes"
      "ca-derivations"
    ];
  };
in
{
  flake.modules.nixos.default = { pkgs, config, ... }: {
    nix = sharedNixConfig { inherit pkgs config; } // {
      gc.dates = "weekly";
    };
  };

  flake.modules.darwin.default = { pkgs, config, ... }: {
    nix = sharedNixConfig { inherit pkgs config; } // {
      gc.interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
    };
  };
}
