{ config, pkgs, ... }:

{
  home.shell.enableZshIntegration = true;

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreAllDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
      extended = true;
    };
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    completionInit = ''
      autoload -Uz compinit
      compinit -C
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
    '';
    initContent = ''
      source ~/.env

      # Vi mode keybindings
      bindkey -M vicmd 'H' beginning-of-line
      bindkey -M vicmd 'L' end-of-line
      bindkey '^p' history-search-backward
      bindkey '^n' history-search-forward
      bindkey '^y' autosuggest-accept

      # Double ESC to prepend sudo to last command
      sudo-command-line() {
        if [[ -z $BUFFER ]]; then
          BUFFER="sudo $(fc -ln -1)"
        else
          BUFFER="sudo $BUFFER"
        fi
        zle end-of-line
      }
      zle -N sudo-command-line
      bindkey '\e\e' sudo-command-line

      # FZF custom completion functions
      # Use fd for path completion
      _fzf_compgen_path() {
        fd --hidden --exclude .git . "$1"
      }

      # Use fd for directory completion
      _fzf_compgen_dir() {
        fd --type=d --hidden --exclude .git . "$1"
      }

      # Advanced customization of fzf options via _fzf_comprun function
      _fzf_comprun() {
        local command=$1
        shift
        
        case "$command" in
          cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
          export|unset) fzf --preview "eval 'echo \''${}" "$@" ;;
          ssh)          fzf --preview 'dig {}'                   "$@" ;;
          *)            fzf --preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi' "$@" ;;
        esac
      }
    '';
    shellAliases = {
      # File operations
      ls = "eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions";
      ll = "eza -ah --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions";
      tree = "eza -TL 3 --color=always --icons=always --git";
      cat = "bat";

      c = "clear";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    silent = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.ripgrep.enable = true;

  programs.fd.enable = true;

  programs.bat = {
    enable = true;
  }; # better cat

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  }; # better cd

  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
  }; # completion

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
    fileWidgetCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
    changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";

    fileWidgetOptions = [
      "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"
    ];

    changeDirWidgetOptions = [
      "--preview 'eza --tree --color=always {} | head -200'"
    ];
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      version = 3;
      final_space = true;

      palette = {
        blue = "#89B4FA";
        closer = "p:os";
        lavender = "#B4BEFE";
        os = "#ACB0BE";
        pink = "#F5C2E7";
        yellow = "#f9e2af";
        green = "#a6e3a1";
      };

      secondary_prompt = {
        template = " ";
        foreground = "p:closer";
      };

      transient_prompt = {
        template = " ";
        foreground_templates = [
          "{{if gt .Code 0}}p:pink{{end}}"
          "{{if eq .Code 0}}p:closer{{end}}"
        ];
      };

      blocks = [
        {
          type = "prompt";
          alignment = "left";
          newline = true;
          segments = [
            {
              template = "{{ .Path }} ";
              foreground = "p:pink";
              type = "path";
              style = "plain";
              properties = {
                folder_icon = "....";
                home_icon = "~";
                style = "agnoster_short";
              };
            }
            {
              template = "{{ .HEAD }} ";
              foreground = "p:lavender";
              type = "git";
              style = "plain";
              properties = {
                branch_icon = " ";
                cherry_pick_icon = " ";
                commit_icon = " ";
                fetch_status = false;
                fetch_upstream_icon = false;
                merge_icon = " ";
                no_commits_icon = " ";
                rebase_icon = " ";
                revert_icon = " ";
                tag_icon = " ";
              };
            }
            {
              type = "nix-shell";
              template = "󱄅 {{ .Type }}";
              foreground = "p:blue";
              style = "plain";
            }
          ];
        }
        {
          type = "rprompt";
          overflow = "hidden";
          segments = [
            {
              type = "project";
              template = " {{ if .Error }}{{ .Error }}{{ else }}{{ if .Version }} {{.Version}}{{ end }} {{ if .Name }}{{ .Name }}{{ end }}{{ end }} ";
              foreground = "p:green";
              style = "plain";
            }
            {
              template = "{{ .FormattedMs }}";
              foreground = "p:yellow";
              type = "executiontime";
              style = "plain";
            }
          ];
        }
        {
          type = "prompt";
          alignment = "left";
          newline = true;
          segments = [
            {
              template = "";
              type = "text";
              style = "plain";
              foreground_templates = [
                "{{if gt .Code 0}}p:pink{{end}}"
                "{{if eq .Code 0}}p:closer{{end}}"
              ];
            }
          ];
        }
      ];
    };
  };

  imports = [
    ./scripting.nix
  ];
}
