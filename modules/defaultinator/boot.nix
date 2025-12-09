{ lib, ... }:
{
  flake.modules.nixos.defaultinator =
    { config, ... }:
    {
      system.stateVersion = "25.05";

      boot = {
        initrd = {
          systemd.enable = lib.mkForce true;
          network = {
            enable = true;
            ssh = {
              enable = true;
              port = 2222;
              authorizedKeys = config.users.users.psivaram.openssh.authorizedKeys.keys;
            };
          };
        };
        loader = {
          systemd-boot.enable = lib.mkDefault true;
          efi.canTouchEfiVariables = lib.mkDefault true;
        };
      };
    };
}
