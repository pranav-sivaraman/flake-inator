{ inputs, ... }:
{
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
          localStorageDir = ./. + "/modules/secrets/rekeyed/${config.networking.hostName}";
          agePlugins = [ pkgs.age-plugin-yubikey ];
        };
      };
    };
}
