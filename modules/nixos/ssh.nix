{
  flake.modules.nixos.default =
    { config, ... }:
    {
      # TODO: don't hardcode psivaram
      services = {
        openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "prohibit-password";
            AllowUsers = [
              "psivaram"
              "root"
            ];
          };
        };
      };

      users.users.root.openssh.authorizedKeys.keys =
        config.users.users.psivaram.openssh.authorizedKeys.keys;
    };

}
