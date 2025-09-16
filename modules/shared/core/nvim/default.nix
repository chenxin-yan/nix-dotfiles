{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    neovim
    imagemagick_light
  ];

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/config/nvim";

  programs.zsh.shellAliases = {
    v = "nvim";
  };
}
