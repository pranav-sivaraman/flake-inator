{ inputs, lib, ... }:
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

    # TODO: Migrate to exportInterfaces when PR #5891 is merged
    # https://git.clan.lol/clan/clan-core/pulls/5891
    #
    # After the PR is merged:
    # 1. Replace `exportsModule` with `exportInterfaces`:
    #    exportInterfaces.route = { lib, ... }: {
    #      options = {
    #        subdomain = lib.mkOption { type = lib.types.str; };
    #        interface = lib.mkOption { type = lib.types.str; default = "localhost"; };
    #        port = lib.mkOption { type = lib.types.str; };
    #      };
    #    };
    #
    # 2. Update services using this export to add `manifest.traits = [ "route" ];`
    #    in their service definition (e.g., oidc.nix)
    #
    # Define custom export schema for route information
    exportsModule = {
      options.route = lib.mkOption {
        default = null;
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              subdomain = lib.mkOption {
                type = lib.types.str;
                description = "Subdomain for the route";
              };
              interface = lib.mkOption {
                type = lib.types.str;
                default = "localhost";
                description = "Interface/host to proxy to";
              };
              port = lib.mkOption {
                type = lib.types.str;
                description = "Port to proxy to";
              };
            };
          }
        );
      };
    };
  };
}
