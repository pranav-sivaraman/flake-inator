{
  flake.modules.homeManager.default =
    { config, pkgs, ... }:
    let
      piPackage = pkgs.pi-coding-agent;
      piExtensions = "${piPackage}/lib/node_modules/pi-monorepo/examples/extensions";
      piNodeModules = "${piPackage}/lib/node_modules/pi-monorepo/node_modules";
      gondolinExtension = pkgs.runCommand "pi-extension-gondolin" { } ''
        mkdir -p "$out"
        cp -R "${piExtensions}/gondolin/." "$out/"
        ln -s "${piNodeModules}" "$out/node_modules"
      '';
    in
    {
      home = {
        packages = [ pkgs.github-mcp-server ];
        sessionVariables = {
          PI_OFFLINE = "1";
        };
      };

      xdg.configFile = builtins.listToAttrs (
        map
          (extension: {
            name = "pi/agent/extensions/${extension}";
            value.source =
              if extension == "gondolin" then gondolinExtension else "${piExtensions}/${extension}";
          })
          [
            "plan-mode"
            "gondolin"
          ]
      );

      programs = {
        mcp = {
          enable = true;
          servers.github = {
            command = "github-mcp-server";
            args = [ "stdio" ];
            environment = {
              GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_PERSONAL_ACCESS_TOKEN}";
            };
          };
        };
        pi-coding-agent = {
          enable = true;
          configDir = "${config.xdg.configHome}/pi/agent";
          # TODO: need to manage the packages differently
          # I do not like setting a default model
          # settings = {
          #   packages = [
          #     "npm:pi-mcp-adapter"
          #   ];
          # };
          extraPackages = with pkgs; [
            nodejs
            qemu
          ];
        };
      };
    };
}
