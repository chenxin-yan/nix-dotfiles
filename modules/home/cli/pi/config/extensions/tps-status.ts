import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const STATUS_KEY = "output-tps";

export function calculateTps(outputTokens: number, startedAtMs: number, endedAtMs: number): number {
  return (outputTokens * 1000) / Math.max(1, endedAtMs - startedAtMs);
}

export default function (pi: ExtensionAPI) {
  let startedAt: number | undefined;
  let estimatedTokens = 0;

  pi.on("message_start", (event, ctx) => {
    if (event.message.role !== "assistant") return;
    startedAt = undefined;
    estimatedTokens = 0;
    ctx.ui.setStatus(STATUS_KEY, ctx.ui.theme.fg("dim", "TPS …"));
  });

  pi.on("message_update", (event, ctx) => {
    const update = event.assistantMessageEvent;
    if (update.type !== "text_delta" && update.type !== "thinking_delta" && update.type !== "toolcall_delta") return;

    const now = performance.now();
    startedAt ??= now;
    estimatedTokens += update.delta.length / 4;
    ctx.ui.setStatus(
      STATUS_KEY,
      ctx.ui.theme.fg("dim", `TPS ~${calculateTps(estimatedTokens, startedAt, now).toFixed(1)}`),
    );
  });

  pi.on("message_end", (event, ctx) => {
    if (event.message.role !== "assistant" || startedAt === undefined) return;
    ctx.ui.setStatus(
      STATUS_KEY,
      ctx.ui.theme.fg("dim", `TPS ${calculateTps(event.message.usage.output, startedAt, performance.now()).toFixed(1)}`),
    );
  });
}
