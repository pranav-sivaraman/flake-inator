{
  flake.aspects.container = {
    homeManager =
      { ... }:
      {
        # Rosetta support for x86_64 container emulation on Apple Silicon (macOS Tahoe+):
        # After first build, run:
        #   podman machine ssh "sudo touch /etc/containers/enable-rosetta"
        #   podman machine stop && podman machine start
        # Verify with: podman machine ssh "cat /proc/sys/fs/binfmt_misc/rosetta"
        services.podman.enable = true;
      };
  };
}
