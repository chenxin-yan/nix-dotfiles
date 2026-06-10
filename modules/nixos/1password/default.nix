{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    nixos._1password.enable = lib.mkEnableOption "enables 1password CLI";
  };

  config = lib.mkIf config.nixos._1password.enable {
    programs._1password.enable = true;
  };
}
