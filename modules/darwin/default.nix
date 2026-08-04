{
  # flake-file.inputs.nix-darwin = {
  #   url = "github:nix-darwin/nix-darwin";
  # };

  flake.modules.darwin.default = {
    system.stateVersion = 7;
    nixpkgs.hostPlatform = "aarch64-darwin";
  };
}
