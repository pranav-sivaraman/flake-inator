{ inputs, lib, ... }:
let
  baseModules = with inputs.self.aspects; [
    psivaram.homeManager
    nix.homeManager
    shell.homeManager
    container.homeManager
    llm.homeManager
  ];

  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];

  mkHomeConfigurations =
    name: modules:
    lib.genAttrs (map (system: "${name}@${system}") systems) (
      key:
      let
        system = lib.removePrefix "${name}@" key;
        isDarwin = lib.hasSuffix "-darwin" system;
        homeDir = if isDarwin then "/Users/${name}" else "/home/${name}";
      in
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        modules = modules ++ [
          { home.homeDirectory = homeDir; }
        ];
      }
    );
in
{
  flake.aspects.home-manager = {
    nixos = {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };
    darwin = {
      imports = [ inputs.home-manager.darwinModules.home-manager ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };
  };

  flake.homeManagerModules = {
    base = baseModules;
    full =
      baseModules
      ++ (with inputs.self.aspects; [
        window-manager.homeManager
        desktop.homeManager
        container.homeManager
        mac.homeManager
        ssh.homeManager
      ]);
  };

  flake.homeConfigurations =
    mkHomeConfigurations "psivaram" baseModules
    // lib.genAttrs (map (system: "sivaramp@${system}") systems) (
      key:
      let
        system = lib.removePrefix "sivaramp@" key;
        isDarwin = lib.hasSuffix "-darwin" system;
        homeDir = if isDarwin then "/Users/sivaramp" else "/home/sivaramp";
      in
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        modules = baseModules ++ [
          (
            { ... }:
            {
              home = {
                username = lib.mkOverride 10 "sivaramp";
                homeDirectory = lib.mkOverride 10 homeDir;
              };
              programs.bash.enable = lib.mkForce false;
            }
          )
        ];
      }
    );
}
