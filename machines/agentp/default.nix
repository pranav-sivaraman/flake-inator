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

  flake.modules.nixos.agentp = {
    hardware = {
      graphics.enable = true;
      nvidia.open = true;
    };
    services = {
      xserver = {
        # enable = true;
        videoDrivers = [ "nvidia" ];
      };
      desktopManager.plasma6.enable = true;
      displayManager.plasma-login-manager.enable = true;
    };
  };
}
