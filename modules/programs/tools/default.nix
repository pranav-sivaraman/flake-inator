{
  flake.aspects.shell = {
    homeManager =
      { pkgs, ... }:
      {
        home = {
          packages = with pkgs; [
            sccache
            cmake
            ninja
            gnumake
            shellcheck
            # cvise # FIXME: add back somehow
            bear
            gh
            uv
          ];
          sessionVariables = {
            CMAKE_EXPORT_COMPILE_COMMANDS = "ON";
            CMAKE_GENERATOR = "Ninja";
            CMAKE_C_COMPILER_LAUNCHER = "sccache";
            CMAKE_CXX_COMPILER_LAUNCHER = "sccache";
            CMAKE_CUDA_COMPILER_LAUNCHER = "sccache";
          };
          shellAliases = {
            sqs = "squeue -u $USER";
          };
        };
        programs = {
          ripgrep.enable = true;
          fd.enable = true;
          direnv = {
            enable = true;
            nix-direnv.enable = true;
          };
        };
      };

  };
}
