{ pkgs, ... }:

{
  home.packages = with pkgs; [
    python313
    uv

    # editor
    ruff
    basedpyright
    python313Packages.debugpy
  ];
}
