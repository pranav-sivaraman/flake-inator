{
  flake.modules.homeManager.default = { pkgs, ... }: {
    programs.man.generateCaches = pkgs.stdenv.hostPlatform.isLinux;
  };
}
