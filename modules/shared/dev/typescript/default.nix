{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs_22
    bun
    pnpm
    ni

    # editor
    vtsls
    nodePackages."@astrojs/language-server"
    vscode-js-debug
  ];
}
