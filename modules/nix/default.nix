let
  sharedNixpkgsConfig = {
    nixpkgs.config.allowUnfree = true;
  };
in
{
  flake.aspects.nix = {
    darwin = sharedNixpkgsConfig;
    nixos = sharedNixpkgsConfig // {
      nix = {
        channel.enable = false;
        optimise.automatic = true;
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    };
    homeManager = { };
  };
}
