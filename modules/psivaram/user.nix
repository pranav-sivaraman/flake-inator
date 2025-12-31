{ inputs, ... }:
let
  userName = import ./_config.nix;
in
{
  clan.inventory.instances = {
    psivaram-user = {
      module.name = "users";
      roles.default.tags.all = { }; # Add this user to all machines
      roles.default.settings = {
        user = "psivaram";
        groups = [
          "wheel" # Allow using 'sudo'
          "networkmanager" # Allows to manage network connections.
          "video" # Allows to access video devices.
          "input" # Allows to access input devices.
        ];
        prompt = false;
        share = true;
      };
    };
  };
  flake.modules.nixos.${userName} = {
    users.users.${userName} = {
      isNormalUser = true;
      description = "psivaram";
      openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBm/NvZHRsOINhjseCZ7aI2DbpaNPyZjw+eXPXpSRvlqAAAAEnNzaDphdXRoZW50aWNhdGlvbg=="
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHiGaA36EZ/k/prPZpZwDN2e85UCTkmlCSmk1StomRqhAAAAEnNzaDphdXRoZW50aWNhdGlvbg=="
      ];
    };
  };
}
