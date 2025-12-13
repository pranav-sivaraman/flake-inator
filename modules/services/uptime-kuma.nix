{
  flake.modules.nixos.uptime-kuma = {
    services.uptime-kuma = {
      enable = true;
      settings = {
        HOST = "192.168.64.2"; # Listen on all interfaces, or use your specific static IP
      };
    };

    environment.persistence."/persist".directories = [
      "/var/lib/private/uptime-kuma"
    ];
  };
}
