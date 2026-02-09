{
  lib,
  config,
  ...
}:

{
  options = {
    cli.mise.enable = lib.mkEnableOption "enables mise dev tool manager";
  };

  config = lib.mkIf config.cli.mise.enable {
    programs.mise = {
      enable = true;
      enableZshIntegration = true;
      globalConfig = {
        settings = {
          experimental = true;
        };
      };
    };
  };
}
