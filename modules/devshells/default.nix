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
            # TODO: this should be an overlay aka pkgs.clan-core
            inputs'.clan-core.packages.default
          ];
        };
      };
    };
}
