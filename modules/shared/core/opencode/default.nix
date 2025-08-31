{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    opencode
  ];

  home.file = {
    ".config/opencode/opencode.json".source = ./config/opencode.json;
  };
}
