{
  flake.modules.homeManager.default = {
    programs.zoxide = {
      enable = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
  };
}
