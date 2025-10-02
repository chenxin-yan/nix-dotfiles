{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mermaid-cli

    markdownlint-cli2
    prettierd
    marksman
    harper
  ];

  home.file.".markdownlint.json".source = ./config/markdownlint.jsonc;
}
