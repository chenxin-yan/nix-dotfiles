{ pkgs, lib, ... }:

{
  programs.aerospace = {
    enable = true;

    # Enable launchd service management
    launchd = {
      enable = true;
      keepAlive = true;
    };

    userSettings = {
      after-login-command = [ ];
      after-startup-command = [
        "exec-and-forget ${lib.getExe' pkgs.sketchybar "sketchybar"}"
      ];
      exec-on-workspace-change = [
        (lib.getExe' pkgs.bash "bash")
        "-c"
        "${lib.getExe' pkgs.sketchybar "sketchybar"} --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
      ];

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

          alt-ctrl-h = "move left";
          alt-ctrl-j = "move down";
          alt-ctrl-k = "move up";
          alt-ctrl-l = "move right";

          alt-ctrl-minus = "resize smart -50";
          alt-ctrl-equal = "resize smart +50";

          ctrl-backtick = "workspace 0";
          ctrl-1 = "workspace 1";
          ctrl-2 = "workspace 2";
          ctrl-3 = "workspace 3";
          ctrl-4 = "workspace 4";
          ctrl-5 = "workspace 5";
          ctrl-6 = "workspace 6";

          alt-ctrl-backtick = "move-node-to-workspace 0";
          alt-ctrl-1 = "move-node-to-workspace 1";
          alt-ctrl-2 = "move-node-to-workspace 2";
          alt-ctrl-3 = "move-node-to-workspace 3";
          alt-ctrl-4 = "move-node-to-workspace 4";
          alt-ctrl-5 = "move-node-to-workspace 5";
          alt-ctrl-6 = "move-node-to-workspace 6";

          alt-tab = "workspace-back-and-forth";

          alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

          alt-ctrl-semicolon = "mode service";
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
          alt-ctrl-h = [
            "join-with left"
            "mode main"
          ];
          alt-ctrl-j = [
            "join-with down"
            "mode main"
          ];
          alt-ctrl-k = [
            "join-with up"
            "mode main"
          ];
          alt-ctrl-l = [
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
          "if".app-id = "com.hnc.Discord";
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
