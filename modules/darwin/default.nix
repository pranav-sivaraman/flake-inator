{ inputs, ... }:
let
  mkDarwinConfig =
    {
      extraModules ? [ ],
    }:
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        inputs.self.aspects.nix.darwin
        inputs.self.aspects.psivaram.darwin
        inputs.home-manager.darwinModules.home-manager
        {
          system.stateVersion = 5;
          nix.enable = false;
          homebrew = {
            enable = true;
            casks = [
              "flux-app"
              "yubico-authenticator"
            ];
            onActivation = {
              cleanup = "zap";
              autoUpdate = true;
              upgrade = true;
            };
          };
        }
        {
          home-manager = {
            # TODO: guard this maybe?
            # when importing this needs to check the context
            useGlobalPkgs = true;
            useUserPackages = true;
            users.psivaram = {
              imports = with inputs.self.modules.homeManager; [
                psivaram
                window-manager
                desktop
                shell
                mac
                nix
              ];
            };
          };
        }
      ]
      ++ extraModules;
    };
in
{
  flake.darwinConfigurations = {
    personal = mkDarwinConfig {
      extraModules = [
        {
          homebrew.casks = [
            "kobo"
            "calibre"
          ];
        }
      ];
    };

    work = mkDarwinConfig {
      extraModules = [
        {
          home-manager.users.psivaram = {
            programs.ssh = {
              includes = [ "~/.ssh/config.hosts" ];
              matchBlocks."*" = {
                user = "sivaramp";
              };
            };
          };
        }
      ];
    };
  };
}
