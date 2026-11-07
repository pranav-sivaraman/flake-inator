{ self, lib, ... }:
let
  # Referencing the runner here (rather than in a hand-written out-link) puts it
  # in the Darwin system's closure via the generated LaunchAgent plist, so
  # nix.gc cannot delete the VM out from under launchd.
  runner = self.nixosConfigurations.microvm-dev.config.microvm.declaredRunner;
in
{
  flake.modules.darwin.default =
    { config, ... }:
    let
      user = config.system.primaryUser;
      stateDir = "/Users/${user}/Library/Application Support/microvm-dev";
      logFile = "/Users/${user}/Library/Logs/microvm-dev.log";
    in
    {
      system.activationScripts.postActivation.text = lib.mkAfter ''
        mkdir -p '${stateDir}' '${dirOf logFile}'
        touch '${logFile}'
        chown -R ${user}:staff '${stateDir}'
        chown ${user}:staff '${logFile}'
      '';

      launchd.user.agents.microvm-dev = {
        environment.PATH = "/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";

        serviceConfig = {
          # The guest console is on stdio, so it ends up in StandardOutPath.
          ProgramArguments = [ "${runner}/bin/microvm-run" ];

          RunAtLoad = true;

          # `true` would fight microvm.nix's `-no-reboot`: a clean poweroff exits
          # 0 and would be immediately restarted. Only restart on failure.
          KeepAlive = {
            SuccessfulExit = false;
          };

          # Relative paths in the guest config (var.img, microvm-dev.sock) resolve
          # against this, so the VM's state lives here, not in the flake checkout.
          WorkingDirectory = stateDir;

          StandardOutPath = logFile;
          StandardErrorPath = logFile;

          ThrottleInterval = 10;
        };
      };
    };
}
