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
          home-manager.darwin
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
          "tailscale-app"
          "prismlauncher"
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
