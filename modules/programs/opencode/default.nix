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
          # TODO: long term use vars to manage API keys
        };
      };
    };
  };
}
