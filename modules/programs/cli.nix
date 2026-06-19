{
  flake.aspects.shell.homeManager = {
    xdg.enable = true;

    home.shellAliases = {
      sqs = "squeue -u $USER";
    };

    programs = {
      eza = {
        enable = true;
        icons = "auto";
        colors = "auto";
      };
      fzf.enable = true;
      fastfetch.enable = true;
      ripgrep.enable = true;
      fd.enable = true;
      gh.enable = true;
      zoxide = {
        enable = true;
        options = [
          "--cmd"
          "cd"
        ];
      };
    };
  };
}
