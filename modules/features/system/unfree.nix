# Separate from Nix prerequisites: onboarding asks before allowing unfree packages.
let
  policy.nixpkgs.config.allowUnfree = true;
in
{
  features.unfree = {
    darwin = policy;
    nixos = policy;
  };
}
