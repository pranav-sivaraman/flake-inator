{
  flake.modules.nixos.agenty = {
    systemd.network = {
      networks = {
        "10-enp0s1" = {
          matchConfig.Name = "enp0s1";
          networkConfig = {
            Address = "192.168.4.3/24";
            Gateway = "192.168.4.1";
            DNS = "192.168.4.1";
          };
        };
      };
    };
  };
}
