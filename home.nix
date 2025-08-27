{ config, pkgs, ... }:

{
  imports = [
    ./config/zsh.nix
  ];

  catppuccin = {
    enable = true;
    flavor = "mocha"; 
    zsh-syntax-highlighting.enable = false;
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "chenxinyan";
  home.homeDirectory = "/home/chenxinyan";

  fonts.fontconfig.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono

    neovim
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/chenxinyan/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
    };
  };

  programs.git = {
    enable = true;

    userName = "Chenxin Yan";
    userEmail = "yanchenxin2004@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autosquash = true;
      push.default = "current";
      fetch.prune = true;
      color.ui = true;
      core.editor = "nvim";
    };

    delta.enable = true;

    # Aliases
    aliases = {
      co = "checkout";
      br = "branch";
      st = "status -sb";
      lg = "log --oneline --graph --decorate";
      amend = "commit --amend --no-edit";
    };
  };

  programs.gh = {
    enable = true;
  
    settings = {
      git_protocol = "https";
      aliases = {
        co = "pr checkout";
      };
    };

    hosts = {
      "github.com" = {
        git_protocol = "ssh";
        users = {
          "chenxin-yan" = {
            user = "chenxin-yan";
          };
        };
      };
    };
  };

  programs.gh-dash.enable = true;

  programs.lazygit.enable = true;

  # SSH client configuration
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        addKeysToAgent = "yes";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };
    };
  };

  # SSH agent service
  services.ssh-agent.enable = true;
}
