{ inputs, ... }:
{
  imports = [
    inputs.clan-core.flakeModules.default
  ];
  clan = {
    meta = {
      name = "owca";
      domain = "praarthana.space";
    };

    secrets.age.plugins = [
      "age-plugin-yubikey"
    ];
  };
}
