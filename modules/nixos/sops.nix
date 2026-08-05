{
  flake.modules.nixos.default = {
    sops.age.sshKeyPaths = [
      "/persist/etc/ssh/ssh_host_ed25519_key"
    ];
    sops.gnupg.sshKeyPaths = [
      "/persist/etc/ssh/ssh_host_rsa_key"
    ];
  };
}
