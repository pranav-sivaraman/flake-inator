{ inputs, ... }:
{
  flake.modules.nixos.vm =
    { config, ... }:
    {
      age = {
        rekey = {
          hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFuPTKBNA2RQBlZeiN1E7fUdg0V++U1Ln5HQlYg5NI6X root@vm";
        };
      };
    };
}
