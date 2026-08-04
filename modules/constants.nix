{ inputs, ... }:
{
  flake.modules.darwin.default = {
    imports = [ inputs.self.modules.generic.constants ];
  };

  flake.modules.nixos.default = {
    imports = [ inputs.self.modules.generic.constants ];
  };

  flake.modules.homeManager.default = {
    imports = [ inputs.self.modules.generic.constants ];
  };

  flake.modules.generic.constants =
    { lib, ... }:
    {
      options.userData = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              name = lib.mkOption { type = lib.types.str; };
              email = lib.mkOption { type = lib.types.str; };
              sshKeys = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
            };
          }
        );
        default = { };
      };

      config.userData = {
        psivaram = {
          name = "Pranav Sivaraman";
          email = "pranavsivaraman@gmail.com";
          sshKeys = [
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBm/NvZHRsOINhjseCZ7aI2DbpaNPyZjw+eXPXpSRvlqAAAAEnNzaDphdXRoZW50aWNhdGlvbg=="
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHiGaA36EZ/k/prPZpZwDN2e85UCTkmlCSmk1StomRqhAAAAEnNzaDphdXRoZW50aWNhdGlvbg=="
          ];
        };
      };
    };
}
