{
  flake.modules.homeManager.default =
    { config, pkgs, ... }:
    let
      flakePath = "${config.home.homeDirectory}/Documents/flake-inator";
    in
    {
      programs.nh = {
        enable = true;
        darwinFlake = pkgs.lib.mkIf pkgs.stdenv.isDarwin flakePath;
      };
    };
}
