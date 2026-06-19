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

        preservation.preserveAt."/persist".directories = [
          {
            directory = "/var/lib/tailscale";
            user = "root";
            group = "root";
            mode = "0700";
          }
        ];

        services.tailscale = {
          enable = true;
          authKeyFile = config.clan.core.vars.generators."tailscale-authkey".files.key.path;
          extraUpFlags = [
            "--login-server=https://headscale.praarthana.space"
            "--hostname=${config.networking.hostName}"
          ];
        };
      };
  };
}
