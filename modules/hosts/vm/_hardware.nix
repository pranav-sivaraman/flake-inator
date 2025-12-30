{ inputs, ... }:
{
  flake.modules.nixos.vm = {
    imports = [ inputs.nixos-facter-modules.nixosModules.facter ];
    config.facter.reportPath = ./facter.json;
  };
}
