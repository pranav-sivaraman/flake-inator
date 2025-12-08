{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.agenix-rekey.flakeModule
  ];
}
