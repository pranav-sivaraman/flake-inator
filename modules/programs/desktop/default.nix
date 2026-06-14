{
  imports = [ ./window-manager.nix ];

  flake.aspects.desktop.homeManager =
    { lib, pkgs, ... }:
    {
      home.packages =
        with pkgs;
        [
          slack
          zotero
        ]
        ++ lib.optionals pkgs.stdenv.isDarwin [
          aldente
          monodraw
        ];
      programs.discord.enable = true;
    };
}
