{ inputs, self, ... }:
{
  flake.modules.nixos.vm =
    { config, ... }:
    {
      age = {
        rekey = {
          hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFuPTKBNA2RQBlZeiN1E7fUdg0V++U1Ln5HQlYg5NI6X root@vm";
        };
        secrets = {
          randomPassword = {
            rekeyFile = self + /modules/secrets/randomPassword.age;
            generator.script = "passphrase";
          };
        };
      };
    };
}
