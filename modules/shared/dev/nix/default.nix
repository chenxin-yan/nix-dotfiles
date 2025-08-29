{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pkgs.nil
    pkgs.nixfmt-rfc-style
  ];
}
