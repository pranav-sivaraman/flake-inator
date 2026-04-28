{ inputs, lib, ... }:
{
  flake.aspects.shell = {
    homeManager =
      { pkgs, ... }:
      let
        themes = [
          "Rosé Pine"
          "Rosé Pine Moon"
          "Rosé Pine Dawn"
        ];

        themeFiles = lib.listToAttrs (
          map (theme: {
            name = "fish/themes/${theme}.theme";
            value.source = "${inputs.rose-pine-fish}/themes/${theme}.theme";
          }) themes
        );

        mkCompletion = cmd: pkg: {
          name = "fish/completions/${cmd}.fish";
          value.source = "${pkg}/share/fish/vendor_completions.d/${cmd}.fish";
        };

        completionFiles = lib.listToAttrs [
          (mkCompletion "eza" pkgs.eza)
          (mkCompletion "nom" pkgs.nix-output-monitor)
          (mkCompletion "podman" pkgs.podman)
          (mkCompletion "skopeo" pkgs.skopeo)
          (mkCompletion "fd" pkgs.fd)
          (mkCompletion "rg" pkgs.ripgrep)
          (mkCompletion "zellij" pkgs.zellij)
        ];
      in
      {
        programs.fish = {
          enable = true;
          interactiveShellInit = ''
            fish_config theme choose "Rosé Pine"
          '';
        };

        xdg.configFile = themeFiles // completionFiles;
      };
  };
}
