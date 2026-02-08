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

      # Define custom export schema for storage information
      options.storage = lib.mkOption {
        default = null;
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              exports = lib.mkOption {
                type = lib.types.listOf (
                  lib.types.submodule {
                    options = {
                      path = lib.mkOption {
                        type = lib.types.str;
                        description = "Path on the storage server where data should be stored";
                        example = "/srv/smb/myservice/data";
                      };
                      mountPoint = lib.mkOption {
                        type = lib.types.str;
                        description = "Path on the client where the storage should be mounted";
                        example = "/mnt/myservice/data";
                      };
                    };
                  }
                );
                description = "List of directories to export and mount";
                example = [
                  {
                    path = "/persist/var/lib/immich/upload";
                    mountPoint = "/var/lib/immich/upload";
                  }
                  {
                    path = "/persist/var/lib/immich/library";
                    mountPoint = "/var/lib/immich/library";
                  }
                ];
              };
              user = lib.mkOption {
                type = lib.types.str;
                description = "User that owns the storage (will be created dynamically on server)";
                example = "myservice";
              };
              group = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Group that owns the storage (defaults to user if empty)";
                example = "myservice";
              };
              readOnly = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether the storage should be read-only";
              };
            };
          }
        );
      };
    };
  };
}
