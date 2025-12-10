{ ... }:
{
  flake.modules.nixos.security = {
    security.pam = {
      rssh.enable = true;
      services.sudo.rssh = true;
    };
  };
}
