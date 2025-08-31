{
  config,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    karabiner-elements
  ];

  xdg.configFile."karabiner" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/config/karabiner";
    recursive = true;
  };
}
