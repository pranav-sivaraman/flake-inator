{ inputs, ... }:
{
  imports = [
    ./ui.nix
    ./theme.nix
    ./visuals.nix
    ./options.nix
    ./autocmds.nix
    ./clipboard.nix
    ./fuzzy-finder.nix
    ./motion.nix
    ./mini.nix
    ./completion.nix
    ./lsp.nix
    ./treesitter.nix
    ./languages.nix
  ];

  flake.aspects.shell = {
    homeManager = {
      imports = [
        inputs.nvf.homeManagerModules.nvf
      ];

      programs.nvf = {
        enable = true;
        defaultEditor = true;
      };
    };
  };
}
