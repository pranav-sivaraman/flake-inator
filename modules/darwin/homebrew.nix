{
  flake.aspects.homebrew.darwin = {
    homebrew = {
      enable = true;
      casks = [
        "flux-app"
        "yubico-authenticator"
        "google-chrome"
        "kobo"
        "calibre"
        "tailscale-app"
        "steam"
        "prismlauncher"
      ];
      onActivation = {
        cleanup = "uninstall";
        autoUpdate = true;
        upgrade = true;
        extraFlags = [
          "--force-cleanup"
        ];
      };
    };
  };
}
