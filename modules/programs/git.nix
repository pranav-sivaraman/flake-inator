{
  flake.aspects.shell.homeManager = {
    programs.git = {
      enable = true;
      ignores = [
        ".git/"
        ".jj/"
        "__cmake_systeminformation/"
      ];
      settings = {
        user = {
          name = "Pranav Sivaraman";
          email = "pranavsivaraman@gmail.com";
        };
      };
    };
  };
}
