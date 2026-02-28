_: {
  perSystem =
    {
      pkgs,
      inputs',
      ...
    }:
    {
      devShells = {
        default = pkgs.mkShellNoCC {
          env = {
            CLAN_NO_COMMIT = 1;
          };
          packages = [
            inputs'.clan-core.packages.default
            pkgs.nix-output-monitor
          ];
        };
      };
    };
}
