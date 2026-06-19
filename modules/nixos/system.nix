{
  flake.aspects.defaults = {
    nixos = {
      security.pam = {
        rssh.enable = true;
        services.sudo.rssh = true;
      };
    };
  };
}
