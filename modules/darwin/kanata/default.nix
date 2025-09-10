{
  config,
  pkgs,
  ...
}:

{
  xdg.configFile."kanata" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/config/kanata";
    recursive = true;
  };
}
