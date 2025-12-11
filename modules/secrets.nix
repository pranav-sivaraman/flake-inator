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
          masterIdentities = [
            (self + /modules/secrets/gesha.pub)
            (self + /modules/secrets/arabica.pub)
          ];
          storageMode = "local";
          localStorageDir = self + "/modules/secrets/rekeyed/${config.networking.hostName}";
          agePlugins = [ pkgs.age-plugin-yubikey ];
        };
      };

      systemd.services.agenix-install-secrets = {
        after = [
          "persist-persist-etc-ssh-ssh_host_ed25519_key.pub.service"
        ];
      };
    };
}
