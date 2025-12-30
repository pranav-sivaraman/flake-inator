{ inputs, self, ... }:
{
  flake.modules.nixos.vm =
    { config, ... }:
    {
      age = {
        rekey = {
          hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTZ/4xmeaeBcDOd/68zyuN/LmQ75aHUMyOehOY8dQdq root@vm";
        };
      };
    };
}
