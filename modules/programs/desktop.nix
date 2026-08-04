{
  flake.modules.homeManager.desktop =
    { lib, pkgs, ... }:
    {
      home.packages =
        with pkgs;
        [
          slack
          zotero
        ]
        ++ lib.optionals pkgs.stdenv.isDarwin [
          monodraw
        ];
      programs = {
        discord.enable = true;
        obsidian.enable = true;
      };
    };
}
