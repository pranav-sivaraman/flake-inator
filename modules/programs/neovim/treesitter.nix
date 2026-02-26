{
  flake.aspects.shell = {
    homeManager =
      { pkgs, ... }:
      {
        programs.nvf.settings.vim = {
          treesitter = {
            enable = true;
            fold = true;
            indent.enable = true;
            highlight.enable = true;
            grammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
              llvm
              ninja
              ssh_config
              mlir
              cuda
              fortran
              csv
              tcl
              dockerfile
            ];
          };
        };
      };
  };
}
