{
  flake.modules.nixos.uptime-kuma = {
    services.uptime-kuma = {
      enable = true;
    };

    environment.persistence."/persist".directories = [
      "/var/lib/private/uptime-kuma"
    ];
  };
}
