{
  features.mosh.homeManager =
    { pkgs, lib, ... }:
    {
      home.packages = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.mosh ];
    };

  features.mosh.nixos = {
    programs.mosh.enable = true;

    networking.firewall.allowedUDPPortRanges = [
      {
        from = 60000;
        to = 61000;
      }
    ];
  };
}
