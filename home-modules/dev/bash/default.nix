{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    dev.bash.enable = lib.mkEnableOption "enables bash development tools";
  };

  config = lib.mkIf config.dev.bash.enable {
    home.packages = with pkgs; [
      bash-language-server
      shellcheck
    ];
  };
}
