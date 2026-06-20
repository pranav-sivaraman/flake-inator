{ inputs, ... }:
{
  _module.args.darwinDefaultConfig =
    {
      system ? "aarch64-darwin",
      extraModules ? [ ],
    }:
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      modules =
        with inputs.self.aspects;
        [
          defaults.darwin
          nix.darwin
          psivaram.darwin
          home-manager.darwin
          homebrew.darwin
        ]
        ++ extraModules;
    };
}
