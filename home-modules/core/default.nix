{ lib, config, ... }:

{
  imports = [
    ./git
    ./nvim
    ./zsh
    ./nushell
  ];

  config = {
    core.git.enable = lib.mkDefault true;
    core.nvim.enable = lib.mkDefault true;
    core.zsh.enable = lib.mkDefault true;
    core.nushell.enable = lib.mkDefault true;
  };
}
