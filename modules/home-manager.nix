{
  inputs,
  ...
}:
{
  # flake-file.inputs.home-manager.url = "github:nix-community/home-manager";

  flake.modules.nixos.default = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager.sharedModules = [
      inputs.self.modules.homeManager.default
    ];
  };

  flake.modules.darwin.default = {
    imports = [ inputs.home-manager.darwinModules.home-manager ];
    home-manager.sharedModules = [
      inputs.self.modules.homeManager.default
    ];
  };

  flake.modules.homeManager.default = {
    backupFileExtension = "bak";
    xdg.enable = true;
  };
}
