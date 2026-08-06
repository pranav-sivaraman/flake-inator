{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        sccache
        cmake
        ninja
        gnumake
        fastmod
        shellcheck
        age-plugin-yubikey
        shfmt
        nix-output-monitor
        nvd
        texliveFull
        nono
      ];
    };
}
