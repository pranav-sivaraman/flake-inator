{
  flake.modules.nixos.vm = {
    networking = {
      hostName = "vm";
      hostId = "f204fc66";
    };
    systemd.network = {
      enable = true;
      networks = {
        "10-enp0s1" = {
          matchConfig.Name = "enp0s1";
          networkConfig = {
            Address = "192.168.64.2/24";
            Gateway = "192.168.64.1";
            DNS = "192.168.64.1";
          };
        };
      };
    };
  };
}
