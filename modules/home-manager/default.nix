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

  flake.homeManagerModules = {
    base = baseModules;
    full =
      baseModules
      ++ (with inputs.self.aspects; [
        desktop.homeManager
      ]);
  };

}
