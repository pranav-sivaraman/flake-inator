{
  flake.modules.darwin.default = {
    homebrew = {
      enable = true;
      casks = [
        "flux-app"
        "yubico-authenticator"
        # TODO: guard this
        "kobo"
        "tailscale-app"
        "steam"
        "prismlauncher"
      ];
      onActivation = {
        cleanup = "uninstall";
        autoUpdate = true;
        upgrade = true;
      };
    };
  };
}
