{ ... }:
{
  flake.aspects.shell = {
    homeManager =
      { ... }:
      {
        programs.git = {
          enable = true;
          settings = {
            user = {
              name = "Pranav Sivaraman";
              email = "pranavsivaraman@gmail.com";
            };
          };
        };
      };
  };
}
