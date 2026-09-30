{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    nixos.mosh.enable = lib.mkEnableOption "enables mosh (mobile shell)";
  };

  config = lib.mkIf config.nixos.mosh.enable {
    programs.mosh.enable = true;

    networking.firewall.allowedUDPPortRanges = [
      {
        from = 60000;
        to = 61000;
      }
    ];
  };
}
