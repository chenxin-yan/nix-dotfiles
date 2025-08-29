{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs_22
    bun
    pnpm

    # editor
    vtsls
    prettierd
    vscode-langservers-extracted
    biome
  ];
}
