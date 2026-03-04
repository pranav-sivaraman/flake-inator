{ inputs, ... }:
let
  mkDarwinConfig =
    {
      extraModules ? [ ],
      homeManagerModules ? inputs.self.homeManagerModules.full,
    }:
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        inputs.self.aspects.nix.darwin
        inputs.self.aspects.psivaram.darwin
        inputs.home-manager.darwinModules.home-manager
        inputs.nix-rosetta-builder.darwinModules.default
        {
          system.stateVersion = 5;
          nix.enable = false;
          nix-rosetta-builder.onDemand = true;
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
            useGlobalPkgs = true;
            useUserPackages = true;
            users.psivaram = {
              imports = homeManagerModules;
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
