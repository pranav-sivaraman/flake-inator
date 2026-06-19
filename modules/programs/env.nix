{
  flake.aspects.shell.homeManager = {
    home.sessionVariables = {
      CMAKE_EXPORT_COMPILE_COMMANDS = "ON";
      CMAKE_GENERATOR = "Ninja";
      CMAKE_C_COMPILER_LAUNCHER = "sccache";
      CMAKE_CXX_COMPILER_LAUNCHER = "sccache";
      CMAKE_CUDA_COMPILER_LAUNCHER = "sccache";
    };
  };
}
