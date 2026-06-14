{
  flake.aspects.shell = {
    homeManager =
      { lib, pkgs, config, ... }:
      lib.mkIf pkgs.stdenv.isDarwin {
        programs.zsh = {
          enable = true;
          dotDir = "${config.xdg.configHome}/zsh";
          initContent = ''
            if [[ $(ps -p $PPID -o comm=) != "zsh" && -z $ZSH_EXECUTION_STRING ]] then
              [[ -o login ]] && LOGIN_OPTION='--login' || LOGIN_OPTION=""
              exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
            fi
          '';
        };
      };
  };
}
