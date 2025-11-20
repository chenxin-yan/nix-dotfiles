{ config, pkgs, ... }:

let
  scriptsDir = "${config.home.homeDirectory}/.local/bin/scripts";
in
{
  home.packages = with pkgs; [
    gum
  ];

  # Gum catppuccin color scheme environment variables
  home.sessionVariables = {
    GUM_STYLE_FOREGROUND = "255";
    GUM_STYLE_BACKGROUND = "234";
    GUM_STYLE_BORDER_FOREGROUND = "139";
    GUM_STYLE_BORDER_BACKGROUND = "234";
    GUM_INPUT_CURSOR_FOREGROUND = "86";
    GUM_INPUT_PROMPT_FOREGROUND = "139";
    GUM_CHOOSE_CURSOR_FOREGROUND = "86";
    GUM_CHOOSE_SELECTED_FOREGROUND = "142";
    GUM_CHOOSE_HEADER_FOREGROUND = "139";
    GUM_TABLE_BORDER_FOREGROUND = "139";
  };

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

      md2pdf = "${scriptsDir}/utils/md2pdf.sh";
    };
  };
}
