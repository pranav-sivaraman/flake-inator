{
  flake.aspects.shell.homeManager = {
    programs.nh = {
      enable = true;
      darwinFlake = "/Users/psivaram/Documents/flake-inator";
    };
  };
}
