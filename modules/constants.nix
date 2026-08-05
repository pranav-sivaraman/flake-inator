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

      options.networkingData = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              staticIp = lib.mkOption { type = lib.types.str; };
              headscaleIp = lib.mkOption { type = lib.types.str; };
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

      # TODO: this probably can be moved into machine definitions but who knows
      # TODO: and should this be a constant who knows
      config.networkingData = {
        agentn = {
          staticIp = "192.168.1.2";
          headscaleIp = "100.64.0.2";
        };
        agentc = {
          staticIp = "192.168.1.3";
          headscaleIp = "100.64.0.1";
        };
      };
    };
}
