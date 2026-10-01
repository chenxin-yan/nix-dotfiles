# Reads config.dotfiles, hence the paths include. The config loads
# vim-wakatime.
{ config, ... }:
{
  features.nvim.includes = with config.features; [
    paths
    wakatime
  ];

  features.nvim.homeManager =
    {
      config,
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        tree-sitter
        imagemagick_light
        neovim
        lua51Packages.tree-sitter-cli
      ];

      xdg.configFile."nvim".source =
        config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/features/cli/nvim/config";

      programs.zsh.shellAliases = {
        v = "nvim";
      };

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };
}
