{ inputs, self, ... }:
{
  flake.modules.nixos.vm =
    { config, ... }:
    {
      age = {
        rekey = {
          hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIc8wYsYK3SfbSFpBJfEOGd75HWwfCiakfy4/G62NtbH root@vm";
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
