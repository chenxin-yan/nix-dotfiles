{
  # Client only; NixOS hosts that accept mosh select mosh-server.
  features.mosh.homeManager =
    { pkgs, lib, ... }:
    {
      home.packages = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.mosh ];
    };
}
