let
  sharedNixpkgsConfig = {
    nixpkgs.config.allowUnfree = true;
  };
in
{
  # flake-file.inputs.nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";

  flake.modules.nixos.default = sharedNixpkgsConfig;
  flake.modules.darwin.default = sharedNixpkgsConfig;
  flake.modules.homeManager.default = sharedNixpkgsConfig;
}
