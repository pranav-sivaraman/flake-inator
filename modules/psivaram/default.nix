let
  username = "psivaram";
in
{
  flake.aspects.psivaram = {
    nixos = {
      users.users.${username} = {
        isNormalUser = true;
        description = "psivaram";
        openssh.authorizedKeys.keys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBm/NvZHRsOINhjseCZ7aI2DbpaNPyZjw+eXPXpSRvlqAAAAEnNzaDphdXRoZW50aWNhdGlvbg=="
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHiGaA36EZ/k/prPZpZwDN2e85UCTkmlCSmk1StomRqhAAAAEnNzaDphdXRoZW50aWNhdGlvbg=="
        ];
      };
    };

    darwin = {
      system.primaryUser = username;
    };

    homeManager =
      { lib, ... }:
      {
        home = {
          inherit username;
          homeDirectory = lib.mkForce "/Users/${username}";
          stateVersion = "25.11";
        };
        programs.home-manager.enable = true;
      };
  };
}
