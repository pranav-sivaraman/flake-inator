{
  flake.aspects.shell = {
    homeManager =
      { lib, pkgs, ... }:
      {
        programs.nvf.settings.vim = {
          lsp.servers.neocmakelsp.cmd = lib.mkForce [
            "${lib.getExe pkgs.neocmakelsp}"
            "stdio"
          ];

          languages = {
            enableTreesitter = true;
            enableDAP = true;
            enableFormat = true;
            enableExtraDiagnostics = true;

            python = {
              enable = true;
              format.type = [ "ruff" ];
              lsp.servers = [ "ty" ];
            };

            nix = {
              enable = true;
              format.type = [ "nixfmt" ];
              lsp.servers = [ "nixd" ];
            };

            assembly.enable = true;
            bash.enable = true;
            hcl.enable = true;
            make.enable = true;
            cmake.enable = true;
            clang.enable = true;
            rust.enable = true;
            markdown.enable = true;
            typst.enable = true;
            toml.enable = true;
            lua.enable = true;
            yaml.enable = true;
          };
        };
      };
  };
}
