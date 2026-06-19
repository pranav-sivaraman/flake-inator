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
          nix.darwin
          psivaram.darwin
          home-manager.darwin
          defaults.darwin
        ]
        ++ extraModules;
    };
}
