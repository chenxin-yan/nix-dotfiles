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
      tree-sitter
      imagemagick_light
      neovim
      copilot-language-server
      github-copilot-cli
    ];

    xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/config/nvim";

    programs.zsh.shellAliases = {
      v = "nvim";
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
