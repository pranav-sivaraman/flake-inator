{
  flake.aspects.shell = {
    homeManager =
      { pkgs, ... }:
      {
        xdg.enable = true;
        home = {
          packages = with pkgs; [
            fastmod
            sccache
            cmake
            ninja
            gnumake
            shellcheck
            age-plugin-yubikey
            texliveFull
            shfmt
            nix-output-monitor
            nvd
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
        # Rosetta support for x86_64 container emulation on Apple Silicon (macOS Tahoe+):
        # After first build, run:
        #   podman machine ssh "sudo touch /etc/containers/enable-rosetta"
        #   podman machine stop && podman machine start
        # Verify with: podman machine ssh "cat /proc/sys/fs/binfmt_misc/rosetta"
        services.podman.enable = true;
        programs = {
          git = {
            enable = true;
            settings = {
              user = {
                name = "Pranav Sivaraman";
                email = "pranavsivaraman@gmail.com";
              };
            };
          };
          eza = {
            enable = true;
            icons = "auto";
            colors = "auto";
          };
          fzf.enable = true;
          fastfetch.enable = true;
          ripgrep.enable = true;
          fd.enable = true;
          direnv = {
            enable = true;
            nix-direnv.enable = true;
            silent = true;
          };
          nh = {
            enable = true;
            darwinFlake = "/Users/psivaram/Documents/flake-inator";
          };
          gh.enable = true;
          uv = {
            enable = true;
            settings = {
              exclude-newer = "7 days";
            };
          };
          zoxide = {
            enable = true;
            options = [
              "--cmd"
              "cd"
            ];
          };
        };
      };

  };
}
