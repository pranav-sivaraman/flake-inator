{ inputs, ... }:
{
  flake.aspects.llm = {
    homeManager =
      { pkgs, ... }:
      {
        home = {
          packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
            pi
          ];
        };
      };
  };
}
