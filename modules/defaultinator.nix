{ lib, ... }:
{
  flake.modules.nixos.defaultinator = {
    system.stateVersion = "25.05";

    boot.loader = {
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true;
    };

    networking.networkmanager.enable = lib.mkDefault true;
    networking.firewall.enable = lib.mkDefault true;

    time.timeZone = "America/New_York";

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };
    };

    security.pam = {
      rssh.enable = true;
      services.sudo.rssh = true;
    };

    nix = {
      channel.enable = false;

      optimise.automatic = true;

      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

    };
  };
}
