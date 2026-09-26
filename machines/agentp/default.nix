{ inputs, ... }:
{
  clan.inventory.machines = {
    agentp = {
      deploy.targetHost = "root@agentp"; # TODO: define this somewhere to easily reference?
    };
  };
  clan.machines.agentp = {
    nixpkgs.hostPlatform = "x86_64-linux";
    imports = with inputs.self.modules.nixos; [
      default
      agentp
      psivaram
      # vpn
    ];
  };

  flake.modules.nixos.agentp =
    { lib, ... }:
    {
      # TODO: move into module
      networking.networkmanager.enable = lib.mkForce true;
      systemd.network.enable = lib.mkForce false;
      preservation.preserveAt."/persist".directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/NetworkManager"
      ];

      hardware = {
        graphics.enable = true;
        nvidia.open = true;
      };
      services = {
        xserver = {
          # enable = true;
          videoDrivers = [ "nvidia" ];
        };
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };
    };
}
