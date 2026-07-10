import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const STATUS_KEY = "agent-time";

export function formatDuration(milliseconds: number): string {
  const totalSeconds = Math.floor(milliseconds / 1000);
  const seconds = totalSeconds % 60;
  const minutes = Math.floor(totalSeconds / 60) % 60;
  const hours = Math.floor(totalSeconds / 3600);

  if (hours) return `${hours}h ${minutes}m ${seconds}s`;
  if (minutes) return `${minutes}m ${seconds}s`;
  return `${seconds}s`;
}

export default function (pi: ExtensionAPI) {
  let startedAt = 0;
  let timer: ReturnType<typeof setInterval> | undefined;

  const stopTimer = () => {
    if (timer) clearInterval(timer);
    timer = undefined;
  };

  pi.on("agent_start", (_event, ctx) => {
    if (!ctx.hasUI) return;
    stopTimer();
    startedAt = performance.now();

    const update = () => {
      ctx.ui.setStatus(
        STATUS_KEY,
        ctx.ui.theme.fg("dim", `work ${formatDuration(performance.now() - startedAt)}`),
      );
    };

    update();
    timer = setInterval(update, 1000);
  });

  pi.on("agent_end", (_event, ctx) => {
    if (!timer) return;
    stopTimer();
    ctx.ui.setStatus(
      STATUS_KEY,
      ctx.ui.theme.fg("dim", `work ${formatDuration(performance.now() - startedAt)}`),
    );
  });

  pi.on("session_shutdown", stopTimer);
}
