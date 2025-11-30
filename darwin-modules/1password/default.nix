{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    darwin._1password.enable = lib.mkEnableOption "enables 1password for nix-darwin";
  };

  config = lib.mkIf config.darwin._1password.enable {
    programs._1password.enable = true;
    programs._1password-gui.enable = true;
  };
}
