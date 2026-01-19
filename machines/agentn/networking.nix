{
  flake.modules.nixos.agentn = {
    systemd.network = {
      networks = {
        "10-enp2s0" = {
          matchConfig.Name = "enp2s0";
          networkConfig = {
            Address = "192.168.1.2/24";
            Gateway = "192.168.1.1";
            DNS = "192.168.1.1";
          };
        };
      };
    };
  };
}
