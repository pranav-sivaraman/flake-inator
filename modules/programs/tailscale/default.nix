{ ... }:
{
  flake.aspects.vpn = {
    nixos =
      {
        config,
        pkgs,
        ...
      }:
      {
        clan.core.vars.generators."tailscale-authkey" = {
          prompts.authkey = {
            description = "Headscale preauth key for Tailscale client enrollment";
            type = "hidden";
          };
          files.key = {
            secret = true;
            owner = "root";
            mode = "0400";
          };
          runtimeInputs = [ pkgs.coreutils ];
          script = ''
            cat $prompts/authkey > $out/key
          '';
        };

        services.tailscale = {
          enable = false;
          authKeyFile = config.clan.core.vars.generators."tailscale-authkey".files.key.path;
          extraUpFlags = [
            "--login-server=https://headscale.praarthana.space"
            "--hostname=${config.networking.hostName}"
          ];
        };
      };
  };
}
