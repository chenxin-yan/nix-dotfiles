{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    dev.web.enable = lib.mkEnableOption "enables web development tools";
  };

  config = lib.mkIf config.dev.web.enable {
    home.packages = with pkgs; [
      curlie
      awscli2
      doppler
      jless

      # editor
      vscode-langservers-extracted
      tailwindcss-language-server
      emmet-language-server
      prettierd
      biome
      taplo
      yaml-language-server
    ];

    programs.jq.enable = true;
  };
}
