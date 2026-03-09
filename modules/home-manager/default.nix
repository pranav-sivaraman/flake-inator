{ inputs, lib, ... }:
let
  baseModules = with inputs.self.aspects; [
    psivaram.homeManager
    nix.homeManager
    shell.homeManager
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
      in
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        inherit modules;
      }
    );
in
{
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
        llm.homeManager
      ]);
  };

  flake.homeConfigurations =
    mkHomeConfigurations "psivaram" baseModules
    // mkHomeConfigurations "sivaramp" (
      baseModules
      ++ [
        (
          { ... }:
          {
            home = {
              username = lib.mkForce "sivaramp";
              homeDirectory = lib.mkForce (builtins.getEnv "HOME");
            };
            programs.bash.enable = lib.mkForce false;
          }
        )
      ]
    );
}
