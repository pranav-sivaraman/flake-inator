{
  flake.aspects.shell = {
    homeManager = {
      programs.gh = {
        enable = true;
      };
    };
  };
}
