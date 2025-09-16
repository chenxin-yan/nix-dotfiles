{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # editor
    gopls
    gofumpt
    gotools
    delve
  ];

  programs.go.enable = true;
}
