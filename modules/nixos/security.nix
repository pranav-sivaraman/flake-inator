{
  flake.modules.nixos.default = {
    security.pam = {
      rssh.enable = true;
      services.sudo.rssh = true;
    };
  };
}
