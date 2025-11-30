{
  "$menu" = "vicinae toggle";
  "$terminal" = "ghostty";

  "$mainMod" = "ALT";
  "$mod" = "SUPER";
  "$hyper" = "SUPER SHIFT ALT CTRL";
  "$meh" = "SHIFT ALT CTRL";

  bind = [
    # Move focus
    "$mainMod, h, movefocus, l"
    "$mainMod, l, movefocus, r"
    "$mainMod, k, movefocus, u"
    "$mainMod, j, movefocus, d"

    # Cycle between recent windows
    "$mod, TAB, cyclenext"
    "$mod SHIFT, TAB, cyclenext, prev"

    # Move windows
    "$mainMod SHIFT, h, movewindow, l"
    "$mainMod SHIFT, l, movewindow, r"
    "$mainMod SHIFT, k, movewindow, u"
    "$mainMod SHIFT, j, movewindow, d"

    # Switch workspaces
    "$mainMod, grave, togglespecialworkspace, magic"
    "$mainMod, 1, workspace, 1"
    "$mainMod, 2, workspace, 2"
    "$mainMod, 3, workspace, 3"
    "$mainMod, 4, workspace, 4"
    "$mainMod, 5, workspace, 5"
    "$mainMod, 6, workspace, 6"
    "$mainMod, 7, workspace, 7"
    "$mainMod, 8, workspace, 8"
    "$mainMod, 9, workspace, 9"
    "$mainMod, 0, workspace, 10"

    "$mainMod SHIFT, grave, movetoworkspace, special:magic"
    "$mainMod SHIFT, 1, movetoworkspace, 1"
    "$mainMod SHIFT, 2, movetoworkspace, 2"
    "$mainMod SHIFT, 3, movetoworkspace, 3"
    "$mainMod SHIFT, 4, movetoworkspace, 4"
    "$mainMod SHIFT, 5, movetoworkspace, 5"
    "$mainMod SHIFT, 6, movetoworkspace, 6"
    "$mainMod SHIFT, 7, movetoworkspace, 7"
    "$mainMod SHIFT, 8, movetoworkspace, 8"
    "$mainMod SHIFT, 9, movetoworkspace, 9"
    "$mainMod SHIFT, 0, movetoworkspace, 10"

    # Toggle floating
    "$mainMod SHIFT, f, togglefloating"

    # Lock screen
    "$meh, L, exec, hyprlock"

    # Application launcher
    "$mod, SPACE, exec, $menu"

    "$mod SHIFT, V, exec, vicinae vicinae://extensions/vicinae/clipboard/history"

    # Close window
    "$mod, q, killactive"

    # Quick Open
    "$hyper, RETURN, exec, $terminal"
  ];

  bindm = [
    # Move/resize windows with mainMod + LMB/RMB and dragging
    "$mainMod, mouse:272, movewindow"
    "$mainMod, mouse:273, resizewindow"
  ];

  binde = [
    # Resize windows
    "$mainMod $mod SHIFT, l, resizeactive, 30 0"
    "$mainMod $mod SHIFT, h, resizeactive, -30 0"
    "$mainMod $mod SHIFT, k, resizeactive, 0 -30"
    "$mainMod $mod SHIFT, j, resizeactive, 0 30"
  ];
  bindd = [
    # Copy / Paste / Select
    "$mod, C, Universal copy, sendshortcut, CTRL, Insert,"
    "$mod, V, Universal paste, sendshortcut, SHIFT, Insert,"
    "$mod, X, Universal cut, sendshortcut, CTRL, X,"
    "$mod, A, Universal select all, sendshortcut, CTRL, A,"

    # Undo / Redo
    "$mod, Z, Universal undo, sendshortcut, CTRL, Z,"
    "$mod SHIFT, Z, Universal redo, sendshortcut, CTRL, Y,"

    # Find
    "$mod, F, Universal find, sendshortcut, CTRL, F,"

    # Save
    "$mod, S, Universal save, sendshortcut, CTRL, S,"
  ];
}
