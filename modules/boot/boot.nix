{ lib, ... }:
{
  flake.modules.nixos.boot = {
    system.stateVersion = "25.05";

    boot = {
      initrd.systemd.enable = lib.mkForce true;
      loader = {
        systemd-boot.enable = lib.mkDefault true;
        efi.canTouchEfiVariables = lib.mkDefault true;
      };
    };
  };
}
