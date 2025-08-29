{ pkgs, ... }:

{
  home.packages = with pkgs; [
    markdownlint-cli2
    prettierd
  ];

  home.file.".markdownlint.json".source = ./config/markdownlint.jsonc;
}
