{
  flake.aspects.vpn = {
    homeManager =
      { pkgs, lib, ... }:
      lib.mkIf pkgs.stdenv.isLinux {
        home = {
          packages = with pkgs; [
            tailscale
          ];
        };
      };
  };
}
