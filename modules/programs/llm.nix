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
          settings = {
            defaultProvider = "deepseek";
            defaultModel = "deepseek-v4-flash";
            packages = [
              "git:github.com/ayghri/i-have-adhd"
            ];
          };
        };
      };
    };
}
