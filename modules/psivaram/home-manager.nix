{ inputs, ... }:
let
  userName = import ./_config.nix;
  configDirs = [
    "nvim"
    "fish"
    "jj"
    "tmux"
    "bat"
  ];
  mkConfigLink = name: {
    name = ".config/${name}";
    value.source = "${inputs.dotfiles.outPath}/${name}/.config/${name}";
  };
in
{
  flake.modules.nixos.${userName} =
    { config, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      home-manager.users.${userName} = {
        imports = [
          inputs.impermanence.homeManagerModules.impermanence
        ];

        home = {
          stateVersion = config.system.stateVersion;
          file = builtins.listToAttrs (map mkConfigLink configDirs);
        };
      };
    };
}
