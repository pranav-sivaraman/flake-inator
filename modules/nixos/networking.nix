{
  flake.modules.nixos.default = {
    networking = {
      firewall.enable = true;
      nftables.enable = true;
      networkmanager.enable = false; # TODO: toggle this potentially?
      useDHCP = false;
      dhcpcd.enable = false;
    };
  };
}
