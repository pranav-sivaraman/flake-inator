{ inputs, ... }:
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
}
