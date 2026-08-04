{
  flake.modules.homeManager.default = {
    programs.nvf.settings.vim = {
      utility = {
        motion.flash-nvim.enable = true;
        smart-splits = {
          enable = true;
        };
      };
    };
  };
}
