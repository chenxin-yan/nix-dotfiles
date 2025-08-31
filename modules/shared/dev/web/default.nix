{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jq
    curlie

    # editor
    prettierd
    vscode-langservers-extracted
    tailwindcss-language-server
    emmet-language-server
    prettierd
    biome
  ];
}
