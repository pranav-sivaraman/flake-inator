{ ... }:
{
  flake.aspects.shell = {
    homeManager =
      { ... }:
      {
        programs.zoxide = {
          enable = true;
          options = [
            "--cmd"
            "cd"
          ];
        };
      };
  };
}
