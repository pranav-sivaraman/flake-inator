{ inputs, ... }:
{
  flake.aspects.llm = {
    homeManager = {
      programs.opencode = {
        enable = true;
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
