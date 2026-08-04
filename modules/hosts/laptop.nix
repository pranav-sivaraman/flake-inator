{ self, inputs, ... }:
{
  flake.darwinConfigurations."Pranavs-MacBook-Air" = inputs.nix-darwin.lib.darwinSystem {
    modules = with self.modules.darwin; [
      default
      psivaram
    ];
  };
}
