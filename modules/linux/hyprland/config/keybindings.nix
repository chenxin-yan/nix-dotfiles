{
  "$windowMod" = "ALT";
  "$workspaceMod" = "CTRL";

  bind = [
    # Move focus
    "$windowMod, left, movefocus, h"
    "$windowMod, right, movefocus, l"
    "$windowMod, up, movefocus, k"
    "$windowMod, down, movefocus, j"

    # Switch workspaces
    "$workspaceMod, ~, togglespecialworkspace, magic"
    "$workspaceMod, 1, workspace, 1"
    "$workspaceMod, 2, workspace, 2"
    "$workspaceMod, 3, workspace, 3"
    "$workspaceMod, 4, workspace, 4"
    "$workspaceMod, 5, workspace, 5"
    "$workspaceMod, 6, workspace, 6"
    "$workspaceMod, 7, workspace, 7"
    "$workspaceMod, 8, workspace, 8"
    "$workspaceMod, 9, workspace, 9"
    "$workspaceMod, 9, workspace, 10"

    # Move active window to a workspace
    "$workspaceMod SHIFT, S, movetoworkspace, special:magic"
    "$workspaceMod SHIFT, 1, movetoworkspace, 1"
    "$workspaceMod SHIFT, 2, movetoworkspace, 2"
    "$workspaceMod SHIFT, 3, movetoworkspace, 3"
    "$workspaceMod SHIFT, 4, movetoworkspace, 4"
    "$workspaceMod SHIFT, 5, movetoworkspace, 5"
    "$workspaceMod SHIFT, 6, movetoworkspace, 6"
    "$workspaceMod SHIFT, 7, movetoworkspace, 7"
    "$workspaceMod SHIFT, 8, movetoworkspace, 8"
    "$workspaceMod SHIFT, 9, movetoworkspace, 9"
    "$workspaceMod SHIFT, 0, movetoworkspace, 10"

  ];

  bindm = [
    # Move/resize windows with mainMod + LMB/RMB and dragging
    "$workspaceMod, mouse:272, movewindow"
    "$workspaceMod, mouse:273, resizewindow"
  ];

  binde = [
    # Resize windows
    "$windowMod ALT SHIFT, l, resizeactive, 30 0"
    "$windowMod ALT SHIFT, h, resizeactive, -30 0"
    "$windowMod ALT SHIFT, k, resizeactive, 0 -30"
    "$windowMod ALT SHIFT, j, resizeactive, 0 30"
  ];
}
