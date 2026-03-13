{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    dev.typescript.enable = lib.mkEnableOption "enables TypeScript development tools";
  };

  config = lib.mkIf config.dev.typescript.enable {
    home.packages = with pkgs; [
      nodejs_25
      pnpm
      ni

      # editor
      vtsls
      nodePackages."@astrojs/language-server"
      vscode-js-debug
    ];

    programs.bun.enable = true;
    home.sessionPath = [ "$HOME/.bun/bin" ];
  };
}
