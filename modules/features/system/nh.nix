{
  features.nh = {
    nixos.programs.nh.enable = true;

    homeManager =
      { lib, pkgs, ... }:
      lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        programs.nh.enable = true;
      };
  };
}
