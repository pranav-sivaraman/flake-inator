let
  sharedNixpkgsConfig = {
    nixpkgs.config.allowUnfree = true;
  };
in
{
  flake.aspects.nix = {
    darwin = sharedNixpkgsConfig;
    nixos = sharedNixpkgsConfig;
    homeManager = { };
  };
}
