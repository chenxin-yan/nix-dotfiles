{ config, pkgs, ... }:

let
  scriptsDir = "${config.home.homeDirectory}/.local/bin/scripts";
in
{
  home.packages = with pkgs; [
    gum
  ];

  home.file = {
    ".local/bin/scripts".source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/scripts";
  };

  programs.zsh = {
    shellAliases = {
      ns = "${scriptsDir}/nix/sync.sh";

      cdv = "cd $DEV_PATH";
      dvc = "${scriptsDir}/dev/clone.sh";
      dvrm = "${scriptsDir}/dev/remove.sh";
      scu = "${scriptsDir}/dev/cleanup.sh";
      se = "${scriptsDir}/dev/attach.sh";

      obs = "${scriptsDir}/obsidian/search.sh";
      obg = "${scriptsDir}/obsidian/grep.sh";
      obc = "${scriptsDir}/obsidian/new_note.sh";

      fzg = "${scriptsDir}/utils/rg_with_fzf.sh";
      dirinit = "${scriptsDir}/dev/dirinit.sh";
    };
  };
}
