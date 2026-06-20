{ lib, ... }:
{
  flake.aspects.boot = {
    nixos = {
      system.stateVersion = "25.05";
      boot = {
        initrd.systemd.enable = true;
        loader = {
          systemd-boot.enable = lib.mkDefault true;
          efi.canTouchEfiVariables = lib.mkDefault true;
        };
      };
    };
  };
}
