# Native Nix garbage collection and store optimisation. The policy is a
# plain file because `just clean` evaluates it directly.
{
  features.nix-gc = {
    darwin = ./_gc-policy.nix;

    nixos = {
      imports = [ ./_gc-policy.nix ];
      nix.gc.dates = "weekly";
    };
  };
}
