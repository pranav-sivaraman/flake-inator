{
  openwrt.router = {
    packages = [
      "losetup"
      "mount-utils"
      "coreutils-stat"
      "htop"
    ];
    providers = {
      dnsmasq = "dnsmasq-full";
    };
    uci.retain = [
      "ucitrack"
      "firewall"
      "luci"
      "rpcd"
    ];
  };
}
