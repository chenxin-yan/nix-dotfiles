{ pkgs, ... }:
{
  home.packages = with pkgs; [
    curlie

    # editor
    prettierd
    vscode-langservers-extracted
    tailwindcss-language-server
    emmet-language-server
    prettierd
    biome
  ];

  programs.jq.enable = true;
}
