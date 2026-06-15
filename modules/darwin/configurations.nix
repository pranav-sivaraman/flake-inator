{ darwinDefaultConfig, ... }:
{
  flake.darwinConfigurations = {
    Pranavs-MacBook-Air = darwinDefaultConfig { };
    HPE-C75C4DFH4W = darwinDefaultConfig {
      extraModules = [
        {
          home-manager.users.psivaram = {
            programs.ssh = {
              includes = [ "~/.ssh/config.hosts" ];
              matchBlocks."*" = {
                user = "sivaramp";
              };
            };
          };
        }
      ];
    };
  };
}
