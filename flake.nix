# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      inputs.import-tree [
        ./modules
        ./machines
      ]
    );

  inputs = {
    clan-core = {
      url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
      inputs.nix-darwin.follows = "nix-darwin";
    };
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    headplane.url = "github:tale/headplane";
    home-manager.url = "github:nix-community/home-manager";
    import-tree.url = "github:vic/import-tree";
    nix-auto-follow = {
      url = "github:fzakaria/nix-auto-follow";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nur.url = "github:nix-community/NUR";
    nvf.url = "github:notashelf/nvf";
    preservation.url = "github:nix-community/preservation";
    rose-pine-btop = {
      url = "github:rose-pine/btop";
      flake = false;
    };
    rose-pine-fish = {
      url = "github:rose-pine/fish";
      flake = false;
    };
    rose-pine-tmtheme = {
      url = "github:rose-pine/tm-theme";
      flake = false;
    };
    rose-pine-zellij = {
      url = "github:rose-pine/zellij";
      flake = false;
    };
    vim-zellij-navigator = {
      url = "https://github.com/hiasr/vim-zellij-navigator/releases/latest/download/vim-zellij-navigator.wasm";
      flake = false;
    };
  };
}
