{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    nixos._1password.enable = lib.mkEnableOption "enables 1password";
  };

  config = lib.mkIf config.nixos._1password.enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "cyan" ];
    };
  };
}
