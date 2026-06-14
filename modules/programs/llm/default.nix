{
  flake.aspects.shell.homeManager =
    { pkgs, ... }:
    {
      home.sessionVariables = {
        PI_OFFLINE = "1";
      };
      programs = {
        pi-coding-agent = {
          enable = true;
          extraPackages = [ pkgs.nodejs ];
          settings = {
            packages = [
              "npm:@ff-labs/pi-fff"
              "npm:context-mode"
              "npm:@upstash/context7-pi"
            ];
          };
        };
      };
    };
}
