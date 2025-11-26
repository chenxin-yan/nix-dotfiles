{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    core.nvim.enable = lib.mkEnableOption "enables neovim editor";
  };

  config = lib.mkIf config.core.nvim.enable {
    home.packages = with pkgs; [
      neovim
      tree-sitter
      imagemagick_light
    ];

    xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/config/nvim";

    programs.zsh.shellAliases = {
      v = "nvim";
    };
  };
}
