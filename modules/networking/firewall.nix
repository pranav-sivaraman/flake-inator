{
  flake.aspects.firewall = {
    nixos = {
      networking.firewall.enable = true;
      networking.nftables.enable = true;
    };
  };
}
