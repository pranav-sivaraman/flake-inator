{
  flake.modules.homeManager.default = { config, ... }:
    let
      username = config.home.username;
    in
    {
      programs.git = {
        enable = true;
        ignores = [
          ".git/"
          ".jj/"
          "__cmake_systeminformation/"
        ];
        settings = {
          user = {
            name = config.userData.${username}.name;
            email = config.userData.${username}.email;
          };
        };
      };
    };
}
