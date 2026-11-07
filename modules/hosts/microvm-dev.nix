{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  microvm-dev = lib.nixosSystem {
    system = "aarch64-linux";

    modules = [
      inputs.self.modules.nixos.microvm-guest
      {
        networking.hostName = "microvm-dev";

        # The runner (qemu itself) has to come from the Darwin package set,
        # otherwise it would try to execute an aarch64-linux qemu on macOS.
        microvm.vmHostPackages = inputs.nixpkgs.legacyPackages.aarch64-darwin;
      }
    ];
  };
in
{
  flake.nixosConfigurations.microvm-dev = microvm-dev;

  # Only advertise the runner on the host system it was built for; flake-parts
  # would otherwise expose a Darwin derivation as packages.{x86_64,aarch64}-linux.
  perSystem =
    { system, ... }:
    lib.optionalAttrs (system == "aarch64-darwin") {
      packages.microvm-dev = microvm-dev.config.microvm.declaredRunner;
    };
}
