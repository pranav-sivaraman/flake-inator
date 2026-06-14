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
            ];
          };
        };
        mcp = {
          enable = true;
          servers.context7 = {
            url = "https://mcp.context7.com/mcp";
          };
        };
      };
    };
}
