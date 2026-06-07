{
  flake.aspects.shell = {
    homeManager =
      { pkgs, ... }:
      {
        xdg.enable = true;
        home = {
          packages = with pkgs; [
            sccache
            cmake
            ninja
            gnumake
            shellcheck
            nix-output-monitor
            age-plugin-yubikey
            texliveFull
            shfmt
            pi-coding-agent
          ];
          sessionVariables = {
            CMAKE_EXPORT_COMPILE_COMMANDS = "ON";
            CMAKE_GENERATOR = "Ninja";
            CMAKE_C_COMPILER_LAUNCHER = "sccache";
            CMAKE_CXX_COMPILER_LAUNCHER = "sccache";
            CMAKE_CUDA_COMPILER_LAUNCHER = "sccache";
            PI_OFFLINE = "1";
          };
          shellAliases = {
            sqs = "squeue -u $USER";
          };
        };
        programs = {
          fastfetch.enable = true;
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
