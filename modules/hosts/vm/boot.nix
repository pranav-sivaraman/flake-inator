{ self, inputs, ... }:
{
  flake.modules.nixos.vm =
    { config, ... }:
    {
      # TODO: use initrd secrets?
      boot.initrd.network.ssh.hostKeys = [ "/etc/initrd-hostkey" ];

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
