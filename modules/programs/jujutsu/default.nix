{ ... }:
{
  flake.aspects.shell.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.watchman ];
      programs.difftastic.enable = true;
      programs.jujutsu = {
        enable = true;
        settings = {
          fsmonitor.backend = "watchman";
          fsmonitor.watchman.register-snapshot-trigger = true;
          git = {
            sign-on-push = true;
          };
          signing = {
            behavior = "drop";
            backend = "ssh";
            # TODO: remove in the future? this is cumbersome
            key = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFFUrmk5b/h/0BXe0ZvWPErKIy1GTCuFrWIXKYqJU8rnAAAAC3NzaDpzaWduaW5n";
          };
          remotes.origin = {
            auto-track-bookmarks = "*";
          };
          templates = {
            commit_trailers = "format_signed_off_by_trailer(self)";
          };
          ui = {
            editor = "nvim";
            default-command = "status";
            diff-formatter = [
              "difft"
              "--color=always"
              "$left"
              "$right"
            ];
            paginate = "never";
          };
          user = {
            name = "Pranav Sivaraman";
            email = "pranavsivaraman@gmail.com";
          };
          aliases = {
            l = [
              "log"
              "-r"
              "ancestors(reachable(@, mutable()), 2)"
            ];
            ll = [
              "log"
              "-n"
              "10"
            ];
            tug = [
              "bookmark"
              "move"
              "--from"
              "heads(::@- & bookmarks())"
              "--to"
              "@-"
            ];
            rebase-all = [
              "rebase"
              "-s"
              "all:roots(trunk()..mutable())"
              "-d"
              "trunk()"
            ];
          };
        };
      };
    };
}
