{ inputs, ... }:
let
  baseModules = with inputs.self.aspects; [
    psivaram.homeManager
    nix.homeManager
    shell.homeManager
    ssh.homeManager
  ];

  homeManagerConfig = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = baseModules;
    backupFileExtension = "bak";
  };
in
{
  flake.aspects.home-manager = {
    nixos = {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager = homeManagerConfig;
    };
    darwin = {
      imports = [ inputs.home-manager.darwinModules.home-manager ];
      home-manager = homeManagerConfig;
    };
  };

}
