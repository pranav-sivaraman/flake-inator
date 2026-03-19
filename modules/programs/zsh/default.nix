{
  flake.aspects.shell = {
    homeManager =
      { pkgs, config, ... }:
      {
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
