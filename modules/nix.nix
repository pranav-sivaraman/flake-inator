{ ... }:
{
  flake.modules.nixos.nix = {
    nixpkgs.config.allowUnfree = true;

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
