{
  flake.aspects.llm = {
    homeManager = {
      programs.claude-code = {
        enable = true;
      };
    };
  };
}
