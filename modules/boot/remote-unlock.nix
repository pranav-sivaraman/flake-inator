{ self, lib, ... }:
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
            port = lib.mkDefault 2222;
            authorizedKeys = config.users.users.psivaram.openssh.authorizedKeys.keys;
            hostKeys = [ "/etc/initrd-hostkey" ];
          };
        };
        systemd = {
          users.root.shell = "/bin/systemd-tty-ask-password-agent";
          # Automatically use the same network configuration as the main system
          network.networks = config.systemd.network.networks;
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
    };
}
