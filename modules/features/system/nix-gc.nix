# Native Nix garbage collection and store optimisation. `just clean` reads
# the retention back from the host's evaluated nix.gc.options.
let
  policy = {
    nix.gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
    nix.optimise.automatic = true;
  };
in
{
  features.nix-gc = {
    darwin = policy;

    nixos = {
      imports = [ policy ];
      nix.gc.dates = "weekly";
    };
  };
}
