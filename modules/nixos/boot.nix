{ lib, ... }:
{
  flake.modules.nixos.default = {
    system.stateVersion = "25.05";
    boot = {
      loader = {
        systemd-boot.enable = lib.mkDefault true;
        efi.canTouchEfiVariables = lib.mkDefault true;
      };
    };
  };
}
