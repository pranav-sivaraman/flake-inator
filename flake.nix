{
  description = "Behold my flake-inator!";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };

    nixpkgs-booklore = {
      url = "github:jvanbruegge/nixpkgs/booklore";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree = {
      url = "github:vic/import-tree";
    };

    flake-aspects = {
      url = "github:vic/flake-aspects";
    };

    clan-core = {
      url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
      inputs.home-manager.follows = "home-manager";
      inputs.nix-darwin.follows = "nix-darwin";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
    };

    systems = {
      url = "github:nix-systems/default";
    };

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

    firefox-ublock-origin = {
      url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      flake = false;
    };

    firefox-sponsorblock = {
      url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
      flake = false;
    };

    firefox-bitwarden = {
      url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
      flake = false;
    };

    firefox-bypass-paywalls-clean = {
      url = "https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-latest.xpi";
      flake = false;
    };

    firefox-refined-github = {
      url = "https://addons.mozilla.org/firefox/downloads/latest/refined-github-/latest.xpi";
      flake = false;
    };

    firefox-obsidian-web-clipper = {
      url = "https://addons.mozilla.org/firefox/downloads/latest/web-clipper-obsidian/latest.xpi";
      flake = false;
    };

    firefox-reddit-enhancement-suite = {
      url = "https://addons.mozilla.org/firefox/downloads/latest/reddit-enhancement-suite/latest.xpi";
      flake = false;
    };

    firefox-dark-reader = {
      url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [
          (import-tree ./modules)
          (import-tree ./machines)
        ];
      }
    );
}
