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
          buildInputs = [ pkgs.fish ];
          env = {
            CLAN_NO_COMMIT = 1;
          };
          shellHook = ''
            # Launch fish if not already in fish
            if [ -z "$FISH_VERSION" ]; then
              exec fish
            fi
          '';
          packages = [
            inputs'.clan-core.packages.default
            pkgs.nix-output-monitor
          ];
        };
      };
    };
}
