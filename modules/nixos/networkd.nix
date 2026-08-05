{
  flake.modules.nixos.default = {
    systemd.network = {
      enable = true;
      # check if this is right or can i Just rely on the auto
      networks = {
        "80-wifi-station" = {
          matchConfig = {
            Type = "wlan";
            WLANInterfaceType = "station";
          };
          networkConfig.DHCP = "yes";
        };
        "89-ethernet" = {
          matchConfig = {
            Kind = "!*";
            Type = "ether";
          };
          networkConfig.DHCP = "yes";
        };
      };
    };
    services.resolved = {
      enable = true;
      settings.Resolve.ReadEtcHosts = false;
    };
  };
}
