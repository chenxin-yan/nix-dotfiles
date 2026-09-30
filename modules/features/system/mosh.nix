{
  # Client only; NixOS hosts that accept mosh select mosh-server.
  features.mosh.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.mosh ];
    };
}
