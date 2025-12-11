{
  flake.modules.nixos.networkd = {
    networking = {
      networkmanager.enable = false;
      useDHCP = false;
      dhcpcd.enable = false;
    };
    systemd.network.enable = true;
    services.resolved.enable = true;
  };
}
