{
  flake.modules.homeManager.default = { pkgs, ... }: {
    programs.man.generateCaches = pkgs.hostPlatform.isLinux;
  };
}
