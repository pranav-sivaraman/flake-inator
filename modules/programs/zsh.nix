{
  flake.aspects.shell = {
    homeManager =
      {
        lib,
        pkgs,
        config,
        ...
      }:
      lib.mkIf pkgs.stdenv.isDarwin {
        programs.zsh = {
          enable = true;
          dotDir = "${config.xdg.configHome}/zsh";
          initContent = ''
            if [[ $(ps -p $PPID -o comm=) != "zsh" && -z $ZSH_EXECUTION_STRING ]] then
              if [[ -o login ]]; then
                exec ${pkgs.fish}/bin/fish --login
              else
                exec ${pkgs.fish}/bin/fish
              fi
            fi
          '';
        };
      };
  };
}
