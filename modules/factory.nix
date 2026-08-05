{ self, lib, ... }:
{
  options.flake.factory = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  config.flake.factory.user = username: {
    nixos."${username}" = { config, ... }: {
      users.users.${username} = {
        isNormalUser = true;
        description = username;
        openssh.authorizedKeys.keys = config.userData.${username}.sshKeys;
      };
      home-manager.users.${username} = {
        imports = [
          self.modules.homeManager.default
        ];
      };
    };
    darwin."${username}" = {
      system.primaryUser = username;
      users.users."${username}".home = "/Users/${username}";
      home-manager.users.${username} = {
        imports = [
          self.modules.homeManager.default
        ];
      };
    };
  };
}
