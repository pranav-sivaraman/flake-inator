{
  flake.modules.homeManager.default = {
    programs.uv = {
      enable = true;
      settings = {
        exclude-newer = "7 days";
      };
    };
  };
}
