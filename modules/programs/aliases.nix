{
  flake.modules.homeManager.default = {
    home.shellAliases = {
      sqs = "squeue -u $USER";
    };
  };
}
