{ inputs, self, ... }:
{
  imports = [
    inputs.agenix-rekey.flakeModule
  ];
  flake.modules.nixos.secrets =
    { config, pkgs, ... }:
    {
      imports = with inputs; [
        agenix.nixosModules.default
        agenix-rekey.nixosModules.default
      ];
      age = {
        rekey = {
          masterIdentities = [ ./secrets/gesha.pub ];
          storageMode = "local";
          localStorageDir = self + "/modules/secrets/rekeyed/${config.networking.hostName}";
          agePlugins = [ pkgs.age-plugin-yubikey ];
        };
      };
    };
}
