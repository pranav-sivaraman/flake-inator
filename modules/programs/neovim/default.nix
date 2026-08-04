{ inputs, ... }:
{
  flake.modules.homeManager.default = {
    imports = [
      inputs.nvf.homeManagerModules.nvf
    ];
    programs.nvf = {
      enable = true;
      defaultEditor = true;
    };
  };
}
