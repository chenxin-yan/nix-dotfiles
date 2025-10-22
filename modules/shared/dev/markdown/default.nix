{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mermaid-cli
    glow

    markdownlint-cli2
    prettierd
    marksman
    harper
  ];

  home.file.".markdownlint.json".source = ./config/markdownlint.jsonc;
}
