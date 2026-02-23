{ ... }:
{
  flake.aspects.shell = {
    homeManager =
      { ... }:
      {
        programs.eza = {
          enable = true;
          icons = "auto";
          colors = "auto";
        };
      };
  };
}
