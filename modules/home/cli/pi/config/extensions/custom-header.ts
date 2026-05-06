/**
 * Custom startup header for pi: minimal text-only subtitle.
 *
 * Replaces the built-in logo + keybinding hints with a single centered
 * `chenxin-yan · pi v<X.Y.Z>` line. No art, no decoration — design intent
 * is "just enough to confirm pi is loaded" and nothing more.
 *
 * Colour hierarchy
 * ----------------
 *   name    → `muted`  (subtitle weight)
 *   `·`     → `dim`    (separator recedes)
 *   version → `dim`    (deprioritised)
 *
 * Restore upstream header
 * -----------------------
 * Run `/builtin-header` mid-session to switch back to the built-in logo
 * + keybinding hints (e.g. when discovering shortcuts). `pi --verbose`
 * overrides `quietStartup` for one launch.
 *
 * Sticky-on-scroll caveat
 * -----------------------
 * Custom headers stay pinned at the top while scrolling. Upstream
 * limitation (badlogic/pi-mono RFE #3415), not configurable.
 */

import type { ExtensionAPI, Theme } from "@mariozechner/pi-coding-agent";
import { VERSION } from "@mariozechner/pi-coding-agent";
import { visibleWidth } from "@mariozechner/pi-tui";

const NAME = "@chenxin-yan";

// Center a single line against the terminal width. `visibleWidth()`
// strips ANSI escapes so colouring before centering stays correct.
function centerLine(line: string, terminalWidth: number): string {
  const w = visibleWidth(line);
  if (w >= terminalWidth) return line;
  return " ".repeat(Math.floor((terminalWidth - w) / 2)) + line;
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;

    ctx.ui.setHeader((_tui, theme: Theme) => ({
      render(width: number): string[] {
        const subtitle =
          theme.fg("muted", NAME) + theme.fg("dim", ` · pi v${VERSION}`);

        return ["", centerLine(subtitle, width), ""];
      },
      invalidate() {},
    }));
  });

  pi.registerCommand("builtin-header", {
    description: "Restore built-in header with keybinding hints",
    handler: async (_args, ctx) => {
      ctx.ui.setHeader(undefined);
      ctx.ui.notify("Built-in header restored", "info");
    },
  });
}
