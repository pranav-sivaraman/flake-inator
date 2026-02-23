{ ... }:
{
  flake.aspects.shell = {
    homeManager =
      { ... }:
      {
        programs.fzf.enable = true;
      };
  };
}
