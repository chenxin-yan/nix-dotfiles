/**
 * TPS + TTFT extension.
 *
 * Shows time-to-first-token and tokens/sec for the current turn in the
 * footer status line. TTFT is measured from message_start to the first
 * text or thinking delta. TPS is estimated live from delta chars during
 * streaming, then snapped to authoritative `usage.output` at message_end.
 * Both values stay sticky in the footer until the next turn starts.
 *
 *   ⏱ 420ms · ⚡87 tok/s ~   while streaming (live, estimated TPS)
 *   ⏱ 420ms · ⚡92 tok/s     after message_end (final, authoritative)
 *
 * Place at ~/.pi/agent/extensions/tps.ts and run `/reload` (or restart pi).
 */

import type {
  ExtensionAPI,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";

// Rough char→token ratio. English prose ≈ 4, dense code ≈ 3.
// We only use this for the live estimate; the final value is authoritative.
const CHARS_PER_TOKEN = 4;

// Minimum render cadence while streaming (ms). Keeps the footer from
// thrashing the TUI on fast streams.
const RENDER_THROTTLE_MS = 100;

// Don't display a live number until we have at least this much elapsed
// time, otherwise the first few deltas produce nonsense spikes.
const MIN_ELAPSED_MS = 250;

const STATUS_KEY = "tps";

export default function (pi: ExtensionAPI) {
  let startedAt = 0;
  let firstDeltaAt = 0;
  let estimatedChars = 0;
  let lastRenderAt = 0;
  let active = false;

  const formatTps = (tps: number, suffix = ""): string => {
    const n = tps >= 100 ? Math.round(tps).toString() : tps.toFixed(1);
    return `⚡${n} tok/s${suffix}`;
  };

  const formatTtft = (ms: number): string => {
    if (ms < 1000) return `⏱ ${Math.round(ms)}ms`;
    return `⏱ ${(ms / 1000).toFixed(2)}s`;
  };

  const render = (ctx: ExtensionContext, text: string) => {
    const theme = ctx.ui.theme;
    ctx.ui.setStatus(STATUS_KEY, theme.fg("dim", text));
  };

  pi.on("message_start", async (event, ctx) => {
    if (event.message.role !== "assistant") return;
    startedAt = Date.now();
    firstDeltaAt = 0;
    estimatedChars = 0;
    lastRenderAt = 0;
    active = true;
    // Don't clear the sticky previous value here — keep it visible until
    // the first delta lands and we have a meaningful new number.
    void ctx;
  });

  pi.on("message_update", async (event, ctx) => {
    if (!active) return;
    const stream = event.assistantMessageEvent;
    if (!stream) return;

    // Count both text and thinking deltas. Reasoning tokens are real
    // generation work; ignoring them makes thinking models look slow.
    if (stream.type === "text_delta" || stream.type === "thinking_delta") {
      if (firstDeltaAt === 0) firstDeltaAt = Date.now();
      estimatedChars += stream.delta.length;
    } else {
      return;
    }

    const now = Date.now();
    const elapsed = now - startedAt;
    if (elapsed < MIN_ELAPSED_MS) return;
    if (now - lastRenderAt < RENDER_THROTTLE_MS) return;
    lastRenderAt = now;

    const tps = estimatedChars / CHARS_PER_TOKEN / (elapsed / 1000);
    const ttft = firstDeltaAt - startedAt;
    render(ctx, `${formatTtft(ttft)} · ${formatTps(tps)}`);
  });

  pi.on("message_end", async (event, ctx) => {
    if (event.message.role !== "assistant") return;
    if (!active) return;
    active = false;

    const elapsedMs = Date.now() - startedAt;
    const elapsedSec = elapsedMs / 1000;
    const outputTokens = event.message.usage?.output ?? 0;
    const ttftPart =
      firstDeltaAt > 0 ? `${formatTtft(firstDeltaAt - startedAt)} · ` : "";

    // Aborted or zero-output turn — show what we have rather than NaN.
    if (elapsedSec < 0.05 || outputTokens <= 0) {
      if (estimatedChars > 0 && elapsedSec >= 0.05) {
        const est = estimatedChars / CHARS_PER_TOKEN / elapsedSec;
        render(ctx, `${ttftPart}${formatTps(est, " ~")}`);
      }
      return;
    }

    const tps = outputTokens / elapsedSec;
    render(ctx, `${ttftPart}${formatTps(tps)}`);
  });

  pi.on("session_start", async (_event, ctx) => {
    // Reset state on new/reloaded session and clear any stale chip.
    startedAt = 0;
    firstDeltaAt = 0;
    estimatedChars = 0;
    lastRenderAt = 0;
    active = false;
    ctx.ui.setStatus(STATUS_KEY, "");
  });
}
