{ lib, ... }:
{
  flake.modules.nixos.networking = {
    networking.networkmanager.enable = lib.mkDefault true;
    networking.firewall.enable = lib.mkDefault true;
  };
}
