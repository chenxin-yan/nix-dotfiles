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
      nodejs_22
      bun
      pnpm
      ni
      # turbo

      # editor
      vtsls
      nodePackages."@astrojs/language-server"
      vscode-js-debug
    ];
  };
}
