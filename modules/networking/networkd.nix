{
  flake.modules.nixos.networkd = {
    networking = {
      networkmanager.enable = false;
      useDHCP = false;
      dhcpcd.enable = false;
    };
    systemd.network = {
      enable = true;
      networks = {
        "89-ethernet" = {
          matchConfig = {
            Kind = "!*";
            Type = "ether";
          };
          networkConfig.DHCP = "yes";
        };
      };
    };
    services.resolved.enable = true;
  };
}
