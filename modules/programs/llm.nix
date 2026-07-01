{
  flake.aspects.shell.homeManager =
    { ... }:
    {
      home.sessionVariables = {
        PI_OFFLINE = "1";
      };
      programs = {
        pi-coding-agent = {
          enable = true;
        };
      };
    };
}
