{
  flake.aspects.defaults = {
    nixos = {
      services.userborn = {
        enable = true;
        passwordFilesLocation = "/persist/etc";
      };
      users.mutableUsers = false;
      security.pam = {
        rssh.enable = true;
        services.sudo.rssh = true;
      };
      sops.age.sshKeyPaths = [
        "/persist/etc/ssh/ssh_host_ed25519_key"
      ];
      sops.gnupg.sshKeyPaths = [
        "/persist/etc/ssh/ssh_host_rsa_key"
      ];
      time.timeZone = "America/New_York";
    };
  };
}
