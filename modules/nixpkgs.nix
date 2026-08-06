let
  sharedNixpkgsConfig = {
    nixpkgs.config.allowUnfree = true;
  };
in
{
  flake-file.inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  flake.modules.nixos.default = sharedNixpkgsConfig;
  flake.modules.darwin.default = sharedNixpkgsConfig;
  flake.modules.homeManager.default = sharedNixpkgsConfig;
}
