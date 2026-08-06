{ inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.dendritic
    inputs.flake-file.flakeModules.nix-auto-follow
  ];

  flake-file.outputs = ''
    inputs:
      inputs.flake-parts.lib.mkFlake { inherit inputs; }
        (inputs.import-tree [ ./modules ./machines ])
  '';
}
