{ inputs, ... }:
{
  flake.aspects.llm = {
    homeManager =
      { pkgs, ... }:
      {
        programs.opencode = {
          enable = true;
          package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
          settings = {
            theme = "rosepine";
            compaction = {
              auto = false;
            };
            plugin = [
              "superpowers@${inputs.superpowers.outPath}"
            ];
            share = "disabled";
            # TODO: long term use vars to manage API keys
          };
        };
      };
  };
}
