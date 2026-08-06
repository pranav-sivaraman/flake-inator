{
  inputs,
  ...
}:
{
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager";

  flake.modules.nixos.default = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
  };

  flake.modules.darwin.default = {
    imports = [ inputs.home-manager.darwinModules.home-manager ];
  };

  flake.modules.homeManager.default = {
    xdg.enable = true;
    home.stateVersion = "26.11";
    programs.home-manager.enable = true;
  };
}
