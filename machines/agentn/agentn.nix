{ inputs, ... }:
{
  clan.inventory.machines = {
    agentn = {
      deploy.targetHost = "psivaram@agentn";
    };
  };
  clan.machines.agentn = {
    nixpkgs.hostPlatform = "x86_64-linux";
    imports =
      (with inputs.self.modules.nixos; [
        agentn
        monitoring
        psivaram
      ])
      ++ (with inputs.self.aspects; [
        boot.nixos
        firewall.nixos
        impermanence.nixos
        locale.nixos
        networkd.nixos
        nix.nixos
        security.nixos
        ssh.nixos
        users.nixos
        zfs.nixos
      ]);
  };

}
