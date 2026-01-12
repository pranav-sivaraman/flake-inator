{
  flake.modules.nixos.users = {
    services.userborn.enable = true;
    users.mutableUsers = false;

    systemd.services.sops-install-secrets-for-users = {
      after = [
        "persist-persist-etc-ssh-ssh_host_ed25519_key.service"
        "persist-persist-etc-ssh-ssh_host_rsa_key.service"
      ];
    };
  };
}
