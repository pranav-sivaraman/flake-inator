{
  flake.modules.nixos.users = {
    services.userborn.enable = true;
    users.mutableUsers = false;
  };
}
