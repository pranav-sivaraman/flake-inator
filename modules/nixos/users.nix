{
  flake.modules.nixos.default = {
    services.userborn = {
      enable = true;
      passwordFilesLocation = "/persist/etc";
    };
    users.mutableUsers = false;
  };
}
