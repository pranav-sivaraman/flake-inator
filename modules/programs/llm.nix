{
  flake.modules.homeManager.default = {
    home = {
      sessionVariables = {
        PI_OFFLINE = "1";
      };
      shellAliases = {
        pi = "nono run --profile nolabs-ai/pi --allow-cwd -- pi";
      };
    };
    programs = {
      pi-coding-agent = {
        enable = true;
      };
    };
  };
}
