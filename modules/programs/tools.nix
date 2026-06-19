{
  flake.aspects.shell.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        fastmod
        sccache
        cmake
        ninja
        gnumake
        shellcheck
        age-plugin-yubikey
        texliveFull
        shfmt
        nix-output-monitor
        nvd
      ];
    };
}
