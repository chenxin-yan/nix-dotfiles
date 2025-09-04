{ pkgs, ... }:
{
  home.packages = with pkgs; [
    curlie
    awscli2
    aws-sam-cli

    # editor
    prettierd
    vscode-langservers-extracted
    tailwindcss-language-server
    emmet-language-server
    prettierd
    biome
    taplo
    yaml-language-server
  ];

  programs.jq.enable = true;
}
