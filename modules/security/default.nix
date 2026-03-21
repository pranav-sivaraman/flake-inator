{
  flake.aspects.security = {
    nixos = {
      security.pam = {
        rssh.enable = true;
        services.sudo.rssh = true;
      };
    };
  };
}
