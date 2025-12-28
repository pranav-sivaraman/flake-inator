{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        router = pkgs.callPackage "${inputs.dewclaw}/default.nix" {
          configuration = import ./_config.nix;
        };
      };
    };
}
