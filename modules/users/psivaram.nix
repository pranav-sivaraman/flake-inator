{
  self,
  config,
  lib,
  ...
}:
let
  userData = config.userData.psivaram;
  username = "psivaram";
in
{
  flake.modules = lib.mkMerge [
    (self.factory.user username userData.sshKeys)
  ];
}
