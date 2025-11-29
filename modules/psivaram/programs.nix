{ ... }:
let
  userName = import ./_config.nix;
in
{
  flake.modules.nixos.${userName} = { pkgs, ... }: {
    programs = {
      neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
      };
      git.enable = true;
      bat.enable = true;
      zoxide = {
        enable = true;
        enableFishIntegration = false;
      };
      fish.enable = true;
      bash = {
        interactiveShellInit = ''
          if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
          fi
        '';
      };
    };
  };
}
