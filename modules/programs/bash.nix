{ ... }:
{
  flake.aspects.shell = {
    homeManager =
      { lib, pkgs, ... }:
      lib.mkIf pkgs.stdenv.isLinux {
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
              if shopt -q login_shell; then
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
