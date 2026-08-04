{ lib, ... }:
{
  options.flake.factory = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  config.flake.factory.user = username: sshKeys: {
    nixos."${username}" = {
      users.users.${username} = {
        isNormalUser = true;
        description = username;
        openssh.authorizedKeys.keys = sshKeys;
      };
    };
    darwin."${username}" = {
      system.primaryUser = username;
    };
  };
}
