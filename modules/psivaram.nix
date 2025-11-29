let
  userName = "psivaram";
in
{
  flake.modules.nixos.${userName} =
    { pkgs, ... }:
    {
      users.users.${userName} = {
        isNormalUser = true;
        description = "psivaram";
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBm/NvZHRsOINhjseCZ7aI2DbpaNPyZjw+eXPXpSRvlqAAAAEnNzaDphdXRoZW50aWNhdGlvbg=="
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHiGaA36EZ/k/prPZpZwDN2e85UCTkmlCSmk1StomRqhAAAAEnNzaDphdXRoZW50aWNhdGlvbg=="
        ];
        packages = with pkgs; [
          jujutsu
        ];
      };

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
