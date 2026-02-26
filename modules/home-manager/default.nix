{ inputs, lib, ... }:
let
  baseModules = with inputs.self.aspects; [
    psivaram.homeManager
    nix.homeManager
    shell.homeManager
  ];
in
{
  flake.homeManagerModules = {
    base = baseModules;
    full =
      baseModules
      ++ (with inputs.self.aspects; [
        window-manager.homeManager
        desktop.homeManager
        mac.homeManager
        ssh.homeManager
        llm.homeManager
      ]);
  };

  flake.homeConfigurations =
    lib.genAttrs
      [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ]
      (
        system:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          modules = baseModules;
        }
      );
}
