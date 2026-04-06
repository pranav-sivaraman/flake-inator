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

    # Custom export interfaces for route and storage information
    exportInterfaces = {
      route =
        { lib, ... }:
        {
          options = {
            subdomain = lib.mkOption {
              type = lib.types.str;
              description = "Subdomain for the route";
            };
            interface = lib.mkOption {
              type = lib.types.str;
              default = "localhost";
              description = "Interface/host to proxy to (legacy, use machineName instead)";
            };
            machineName = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Machine name to proxy to, domain will be appended automatically. Preferred over interface.";
            };
            # TODO: replace with type port
            port = lib.mkOption {
              type = lib.types.str;
              description = "Port to proxy to";
            };
          };
        };

      storage =
        { lib, ... }:
        {
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
        };
    };
  };
}
