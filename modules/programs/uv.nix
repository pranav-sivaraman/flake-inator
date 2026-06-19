{
  flake.aspects.shell.homeManager = {
    programs.uv = {
      enable = true;
      settings = {
        exclude-newer = "7 days";
      };
    };
  };
}
