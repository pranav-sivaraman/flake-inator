{
  flake.aspects.container = {
    homeManager =
      { lib, pkgs, ... }:
      lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin {
          services.colima.enable = true;
          home = {
            packages = with pkgs; [
              docker
            ];
          };
        })
        (lib.mkIf pkgs.stdenv.isLinux {
          services.podman.enable = true;
        })
      ];
  };
}
