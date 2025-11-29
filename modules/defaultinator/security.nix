{ ... }:
{
  flake.modules.nixos.defaultinator = {
    security.pam = {
      rssh.enable = true;
      services.sudo.rssh = true;
    };
  };
}
