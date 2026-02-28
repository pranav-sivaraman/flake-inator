{
  flake.aspects.desktop = {
    homeManager =
      { pkgs, ... }:
      {
        home = {
          packages = with pkgs; [
            slack
            # zotero FIXME: uncomment when you actually use it
          ];
        };
        programs.discord.enable = true;
      };
  };
  flake.aspects.mac = {
    homeManager =
      { pkgs, ... }:
      {
        home = {
          packages = with pkgs; [
            aldente
            monodraw
          ];
        };
      };
  };
}
