{ ... }:
{
  flake.aspects.shell = {
    homeManager =
      { pkgs, ... }:
      {
        programs.bash = {
          enable = true;
          historyControl = [
            "erasedups"
            "ignorespace"
          ];
          historySize = -1;
          historyFileSize = -1;
          initExtra = ''
            if [[ $(ps -p $PPID -o comm=) != "bash" && -z $BASH_EXECUTION_STRING ]] ; then
              shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
              exec ${pkgs.fish}/bin/fish "$LOGIN_OPTION"
            fi
          '';
        };
      };
  };
}
