{ ... }:
let
  userName = import ./_config.nix;
in
{
  flake.modules.nixos.${userName} = { pkgs, ... }: {
    users.users.${userName}.packages = with pkgs; [
      jujutsu
      difftastic
      gcc
      tree-sitter
      nodejs
      nixd
      nixfmt
      lua-language-server
      ruff
      ty
      tinymist
      fzf
      claude-code
      fd
      ripgrep
    ];
  };
}
