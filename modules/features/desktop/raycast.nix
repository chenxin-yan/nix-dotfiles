# Raycast, the Mac's launcher on Cmd+Space (Vicinae is Linux's). The cask,
# not nixpkgs' raycast: Raycast updates itself, which a read-only store path
# can't, and keeps one /Applications path for its permissions. Its own
# settings (hotkey, extensions) stay in Raycast, synced by its account.
{
  features.raycast.darwin =
    { config, lib, ... }:
    let
      user = lib.escapeShellArg config.system.primaryUser;
    in
    {
      homebrew.casks = [ "raycast" ];

      # Free Cmd+Space: turn off Spotlight's shortcut (symbolic hotkey 64).
      # -dict-add merges this one key; system.defaults.CustomUserPreferences
      # would replace all of AppleSymbolicHotKeys, resetting every other
      # shortcut changed in System Settings. Applies from the next login.
      system.activationScripts.userDefaults.text = lib.mkAfter ''
        launchctl asuser "$(id -u -- ${user})" sudo --user=${user} -- \
          defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
          -dict-add 64 '<dict><key>enabled</key><false/></dict>'
      '';
    };
}
