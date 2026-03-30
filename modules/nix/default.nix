let
  sharedNixConfig = {
    nixpkgs.config.allowUnfree = true;
    nix = {
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
  };
in
{
  flake.aspects.nix = {
    darwin = sharedNixConfig // {
      nix.gc.interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
    };
    nixos = sharedNixConfig // {
      nix.gc.dates = "weekly";
    };
    homeManager = { };
  };
}
