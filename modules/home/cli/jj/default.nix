{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    cli.jj.enable = lib.mkEnableOption "enables jj (jujutsu) version control system";
  };

  config = lib.mkIf config.cli.jj.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = config.programs.git.userName;
          email = config.programs.git.userEmail;
        };
      };
    };

    home.packages = with pkgs; [
      lazyjj
    ];

    programs.delta = {
      enable = true;
      enableJujutsuIntegration = true;
    };

    programs.jjui = {
      enable = true;
    };

    programs.zsh = {
      shellAliases = {
        j = "jj";
      };
    };
  };
}
