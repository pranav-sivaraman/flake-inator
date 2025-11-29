{ lib, ... }:
{
  flake.modules.nixos.defaultinator = {
    networking.networkmanager.enable = lib.mkDefault true;
    networking.firewall.enable = lib.mkDefault true;
  };
}
