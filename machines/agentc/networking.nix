{
  flake.modules.nixos.agentc = {
    systemd.network = {
      networks = {
        "10-eno2" = {
          matchConfig.Name = "eno2";
          networkConfig = {
            Address = "192.168.1.3/24";
            Gateway = "192.168.1.1";
            DNS = "192.168.1.1";
          };
        };
      };
    };
  };
}
