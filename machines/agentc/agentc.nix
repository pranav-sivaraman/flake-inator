{ inputs, ... }:
{
  clan.inventory.machines = {
    agentc = {
      deploy.targetHost = "psivaram@agentc"; # TODO: define this somewhere to easily reference?
    };
  };
  clan.machines.agentc = {
    nixpkgs.hostPlatform = "x86_64-linux";
    imports =
      (with inputs.self.modules.nixos; [
        agentc
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
