{
  flake.modules.nixos.firewall = {
    networking.firewall.enable = true;
    networking.nftables.enable = true;
  };
}
