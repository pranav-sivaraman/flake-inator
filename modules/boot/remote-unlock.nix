{ self, ... }:
{
  flake.modules.nixos.remote-unlock =
    { config, ... }:
    {
      # TODO: need to find a way to have 1 step deploy for initrd secrets
      # TODO: 1 way is to use age-plugin-tpm?
      boot.initrd = {
        network = {
          enable = true;
          ssh = {
            enable = true;
            port = 2222;
            authorizedKeys = config.users.users.psivaram.openssh.authorizedKeys.keys;
            hostKeys = [ "/etc/initrd-hostkey" ];
          };
        };
        systemd.network = {
          networks = {
            "10-enp0s1" = {
              matchConfig.Name = "enp0s1";
              networkConfig = {
                Address = "192.168.64.2/24";
                Gateway = "192.168.64.1";
                DNS = "192.168.64.1";
              };
            };
          };
        };
      };

      age.secrets = {
        hostkey-initrd = {
          rekeyFile = self + "/modules/secrets/${config.networking.hostName}/hostkey-initrd.age";
          generator.script = "ssh-ed25519";
          path = "/etc/initrd-hostkey";
          symlink = false;
        };
      };

      environment.persistence."/persist".files = [
        "/etc/initrd-hostkey"
      ];
    };
}
