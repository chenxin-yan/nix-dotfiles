// Surfingkeys: keyboard control of web pages in Helium (`?` lists every key).
// Read on every page load from ~/.surfingkeys.js, a link to this file
// (features/gui/helium), so edits apply on reload, with no switch needed.
// Each machine needs "Load settings from" set to <native> once, in
// Surfingkeys' settings page.

// T always opens the omnibar (centered, the default position) instead of
// tab hints.
settings.tabsThreshold = 0;

// Cmd+O: switch tabs in the centered omnibar. Linux delivers it as Ctrl+O
// (xremap). On pages extensions can't run on (new tab, settings), Helium's own
// tab search takes the same key.
const chooseTab = () => api.Front.openOmnibar({ type: "Tabs" });
api.mapkey("<Meta-o>", "Choose a tab", chooseTab);
api.mapkey("<Ctrl-o>", "Choose a tab", chooseTab);
