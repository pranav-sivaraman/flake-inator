{ ... }:
{
  clan.modules.backups =
    { clanLib, ... }:
    {
      _class = "clan.service";
      manifest.name = "backups";
      manifest.readme = "Restic backup service for backing up client machines to a central server.";

      roles.server = {
        description = "Hosts the restic REST server that stores backups.";
        perInstance =
          { roles, ... }:
          {
            nixosModule =
              {
                pkgs,
                lib,
                config,
                ...
              }:
              let
                clientMachines = lib.attrNames (roles.client.machines or { });
                htpasswdEntries = lib.filter (x: x != null) (
                  map (
                    name:
                    clanLib.getPublicValue {
                      flake = config.clan.core.settings.directory;
                      machine = name;
                      generator = "restic-password";
                      file = "htpasswd-entry";
                      default = null;
                    }
                  ) clientMachines
                );
                htpasswdFile = pkgs.writeText "htpasswd" (lib.concatStringsSep "\n" htpasswdEntries);
              in
              {
                services.restic.server = {
                  enable = true;
                  appendOnly = true;
                  "htpasswd-file" = htpasswdFile;
                };

                networking.firewall.allowedTCPPorts = [ 8000 ];
              };
          };
      };

      roles.client = {
        description = "Backs up data to the restic server.";
        perInstance =
          { ... }:
          {
            nixosModule =
              { pkgs, config, ... }:
              {
                clan.core.vars.generators.restic-password = {
                  files.passphrase.secret = true;
                  files.htpasswd-entry.secret = false;
                  runtimeInputs = [
                    pkgs.coreutils
                    pkgs.xkcdpass
                    pkgs.apacheHttpd
                  ];
                  script = ''
                    xkcdpass -n 6 -d - > $out/passphrase
                    htpasswd -nbB "${config.networking.hostName}" "$(cat $out/passphrase)" > $out/htpasswd-entry
                  '';
                };
              };
          };
      };
    };

  clan.inventory.instances.backups = {
    module.input = "self";
    roles.server.machines.agentn = { };
    roles.client.machines.agentc = { };
  };
}
