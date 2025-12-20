{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    app.shared.neomutt.enable = lib.mkEnableOption "enables neomutt email client";
  };

  config = lib.mkIf config.app.shared.neomutt.enable {
    programs.neomutt = {
      enable = true;
      vimKeys = true;
    };

    accounts.email.accounts = {

    };
  };
}
