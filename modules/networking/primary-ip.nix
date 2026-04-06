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
}
