{
  config,
  lib,
  ...
}:

{
  options = {
    core.nushell.enable = lib.mkEnableOption "enables nushell with configuration";
  };

  config = lib.mkIf config.core.nushell.enable {
    programs.nushell = {
      enable = true;
    };
  };
}
