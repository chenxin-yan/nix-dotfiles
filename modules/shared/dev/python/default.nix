{ pkgs, ... }:

{
  home.packages = with pkgs; [
    python313

    # editor
    ruff
    basedpyright
  ];
}
