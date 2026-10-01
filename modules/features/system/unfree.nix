let
  policy.nixpkgs.config.allowUnfree = true;
in
{
  features.unfree = {
    darwin = policy;
    nixos = policy;
  };
}
