{
  flake.aspects.window-manager = {
    homeManager =
      { lib, pkgs, ... }:
      lib.mkIf pkgs.stdenv.isDarwin {
        services.colima.enable = true;
        home = {
          packages = with pkgs; [
            docker
          ];
        };
      };
  };
}
