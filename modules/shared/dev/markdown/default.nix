{ pkgs, ... }:

{
  home.packages = with pkgs; [
    markdownlint-cli2
    prettierd
    marksman
    harper
  ];

  home.file.".markdownlint.json".source = ./config/markdownlint.jsonc;
}
