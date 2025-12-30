{
  lib,
  ...
}:
{
  flake.modules.nixos.remote-unlock =
    { config, pkgs, ... }:
    {
      clan.core.vars.generators.initrd-ssh = {
        files."id_ed25519".neededFor = "activation";
        files."id_ed25519.pub".secret = false;
        runtimeInputs = [
          pkgs.coreutils
          pkgs.openssh
        ];
        script = ''
          ssh-keygen -t ed25519 -N "" -f $out/id_ed25519
        '';
      };

      boot.initrd = {
        network = {
          enable = true;
          ssh = {
            enable = true;
            port = lib.mkDefault 2222;
            hostKeys = [
              config.clan.core.vars.generators.initrd-ssh.files.id_ed25519.path
            ];
            authorizedKeys = config.users.users.psivaram.openssh.authorizedKeys.keys;
          };
        };
        systemd = {
          users.root.shell = "/bin/systemd-tty-ask-password-agent";
          # Automatically use the same network configuration as the main system
          network.networks = config.systemd.network.networks;
        };
      };

    };
}
