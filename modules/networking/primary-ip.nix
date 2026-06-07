{ lib, ... }:
{
  options.networking.primaryIp = lib.mkOption {
    type = lib.types.str;
    description = ''
      The primary IP address of this machine used for service binding.
      On a LAN this is the LAN IP. When transitioning to a multi-subnet
      setup (e.g. Tailscale), change this to the Tailscale IP.
    '';
    example = "192.168.1.3";
  };

  options.networking.headscaleIp = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = ''
      The Headscale/Tailscale IP address of this machine, used for tailnet-only
      DNS records and other VPN-facing references.
    '';
    example = "100.64.0.1";
  };
}
