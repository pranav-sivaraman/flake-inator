{ inputs, ... }:
let
  darwinSystem =
    modules:
    inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules =
        with inputs.self.aspects;
        [
          nix.darwin
          psivaram.darwin
          darwin.base
          darwin.homebrew
          darwin.home-manager
          inputs.home-manager.darwinModules.home-manager
        ]
        ++ modules;
    };
in
{
  flake.darwinConfigurations = {
    personal = darwinSystem [
      {
        homebrew.casks = [
          "kobo"
          "calibre"
        ];
      }
    ];

    work = darwinSystem [
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
}
