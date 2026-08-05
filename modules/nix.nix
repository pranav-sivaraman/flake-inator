let
  sharedNixConfig = {
    enable = true;
    channel.enable = false;
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
in
{
  flake.modules.nixos.default = {
    nix = sharedNixConfig // {
      gc.dates = "weekly";
    };
  };

  flake.modules.darwin.default = {
    nix = sharedNixConfig // {
      gc.interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
    };
  };
}
