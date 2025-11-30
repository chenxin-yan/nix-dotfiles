{
  config,
  pkgs,
  inputs,
  ...
}:

{

  imports = [
    ../../modules/darwin
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.kanata
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    interval = [ { Weekday = 7; } ]; # Sunday (any time)
    options = "--delete-older-than 7d";
  };

  # Automatic Nix store optimization
  nix.optimise = {
    automatic = true;
    interval = [ { Weekday = 7; } ]; # Sunday (any time)
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = config.rev or config.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  system.primaryUser = "yanchenxin";

  programs.zsh.enable = true;
  users.users.${config.system.primaryUser} = {
    name = "${config.system.primaryUser}";
    home = "/Users/${config.system.primaryUser}";
    shell = pkgs.zsh;
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.sketchybar-app-font
  ];

  # Kanata system daemon
  launchd.daemons.kanata = {
    serviceConfig = {
      ProgramArguments = [
        "/run/current-system/sw/bin/kanata"
        "--cfg"
        "/Users/${config.system.primaryUser}/.config/kanata/kanata.kbd"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      UserName = "root";
      StandardOutPath = "/Users/${config.system.primaryUser}/Library/Logs/kanata.log";
      StandardErrorPath = "/Users/${config.system.primaryUser}/Library/Logs/kanata.error.log";
    };
  };

  homebrew = {
    enable = true;
    casks = [
      "ghostty"
      "iina"
      "karabiner-elements"
    ];
    onActivation.cleanup = "zap";
  };

  services.sketchybar.enable = true;

  services.tailscale.enable = true;

  services.aerospace = {
    enable = true;
    settings = {
      after-login-command = [ ];
      # after-startup-command = [
      #   "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar"
      # ];
      exec-on-workspace-change = [
        "${pkgs.bash}/bin/bash"
        "-c"
        "${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
      ];

      on-focus-changed = [ "move-mouse window-lazy-center" ];

      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      accordion-padding = 20;
      default-root-container-layout = "accordion";
      default-root-container-orientation = "auto";
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
      automatically-unhide-macos-hidden-apps = false;

      key-mapping.preset = "qwerty";
      gaps = {
        inner = {
          horizontal = 6;
          vertical = 6;
        };
        outer = {
          left = 6;
          bottom = 6;
          top = [
            { monitor."LG" = 44; }
            12
          ];
          right = 6;
        };
      };
      mode = {
        main.binding = {
          alt-slash = "layout tiles horizontal vertical";
          alt-comma = "layout accordion horizontal vertical";

          alt-h = "focus left";
          alt-j = "focus down";
          alt-k = "focus up";
          alt-l = "focus right";

          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";

          alt-cmd-shift-h = "resize width +30";
          alt-cmd-shift-l = "resize width -30";
          alt-cmd-shift-k = "resize height +30";
          alt-cmd-shift-j = "resize height -30";

          alt-backtick = "workspace 0";
          alt-1 = "workspace 1";
          alt-2 = "workspace 2";
          alt-3 = "workspace 3";
          alt-4 = "workspace 4";
          alt-5 = "workspace 5";
          alt-6 = "workspace 6";

          alt-shift-backtick = "move-node-to-workspace 0";
          alt-shift-1 = "move-node-to-workspace 1";
          alt-shift-2 = "move-node-to-workspace 2";
          alt-shift-3 = "move-node-to-workspace 3";
          alt-shift-4 = "move-node-to-workspace 4";
          alt-shift-5 = "move-node-to-workspace 5";
          alt-shift-6 = "move-node-to-workspace 6";

          alt-tab = "workspace-back-and-forth";

          alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

          alt-shift-semicolon = "mode service";
        };
        service.binding = {
          esc = [
            "reload-config"
            "mode main"
          ];
          r = [
            "flatten-workspace-tree"
            "mode main"
          ];
          f = [
            "layout floating tiling"
            "mode main"
          ];
          backspace = [
            "close-all-windows-but-current"
            "mode main"
          ];
          alt-shift-h = [
            "join-with left"
            "mode main"
          ];
          alt-shift-j = [
            "join-with down"
            "mode main"
          ];
          alt-shift-k = [
            "join-with up"
            "mode main"
          ];
          alt-shift-l = [
            "join-with right"
            "mode main"
          ];
        };
      };
      on-window-detected = [
        {
          "if".app-id = "com.apple.mail";
          run = "move-node-to-workspace 0";
        }
        {
          "if".app-id = "com.microsoft.VSCode";
          run = "move-node-to-workspace 1";
        }
        {
          "if".app-id = "app.zen-browser.zen";
          run = "move-node-to-workspace 2";
        }
        {
          "if".app-id = "com.vivaldi.Vivaldi";
          run = "move-node-to-workspace 2";
        }
        {
          "if".app-id = "com.omnigroup.OmniFocus4";
          run = "move-node-to-workspace 3";
        }
        {
          "if".app-id = "com.flexibits.fantastical2.mac";
          run = "move-node-to-workspace 3";
        }
        {
          "if".app-id = "com.lukilabs.lukiapp-setapp";
          run = "move-node-to-workspace 4";
        }
        {
          "if".app-id = "md.obsidian";
          run = "move-node-to-workspace 4";
        }
        {
          "if".app-id = "dev.vencord.vesktop";
          run = "move-node-to-workspace 5";
        }
        {
          "if".app-id = "com.tencent.xinWeChat";
          run = "move-node-to-workspace 5";
        }
        {
          "if".app-id = "com.tinyspeck.slackmacgap";
          run = "move-node-to-workspace 5";
        }
        {
          "if".app-id = "com.apple.Music";
          run = "move-node-to-workspace 6";
        }
      ];
    };
  };
}
