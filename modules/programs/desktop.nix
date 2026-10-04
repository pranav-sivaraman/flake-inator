{ inputs, ... }:
{
  flake-file.inputs.nixpkgs-zotero = {
    url = "github:NixOS/nixpkgs/7a0f122f5090cf4c2ade2a13a0e229d4e19ba71f";
  };

  flake.modules.homeManager.desktop =
    { lib, pkgs, ... }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          zotero = inputs.nixpkgs-zotero.legacyPackages.${prev.stdenv.hostPlatform.system}.zotero;
        })
      ];

      home.packages =
        with pkgs;
        [
          slack
          zotero
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
          monodraw
        ];
      programs = {
        discord.enable = true;
        obsidian.enable = true;
      };
    };
}
