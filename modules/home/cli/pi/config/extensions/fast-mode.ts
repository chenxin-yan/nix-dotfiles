// GPT-5.6 fast mode toggle. Injects `service_tier: "fast"` into OpenAI
// Responses payloads for eligible models. Same intelligence, up to ~2.5x
// faster inference at 2x API token pricing; long-context requests are
// rejected by the tier. Replaces @pi-plugins/fast-mode (which sent the
// legacy `"priority"` value).
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const STATUS_KEY = "fast-mode";
// provider/model-id pairs fast mode applies to.
const MODELS = new Set([
  "openai/gpt-5.6",
  "openai/gpt-5.6-sol",
  "openai/gpt-5.6-terra",
  "openai/gpt-5.6-luna",
  "openai-codex/gpt-5.6",
  "openai-codex/gpt-5.6-sol",
  "openai-codex/gpt-5.6-terra",
  "openai-codex/gpt-5.6-luna",
]);
// Codex rejects the new "fast" value; it only accepts the legacy "priority".
const TIER_BY_API: Record<string, string> = {
  "openai-responses": "fast",
  "openai-codex-responses": "priority",
};

export default function (pi: ExtensionAPI) {
  let enabled = false;

  const eligible = (model: ExtensionContext["model"]) =>
    model !== undefined && MODELS.has(`${model.provider}/${model.id}`) && model.api in TIER_BY_API;

  const updateStatus = (ctx: ExtensionContext) => {
    if (!ctx.hasUI) return;
    ctx.ui.setStatus(
      STATUS_KEY,
      enabled && eligible(ctx.model) ? ctx.ui.theme.fg("accent", "[fast]") : undefined,
    );
  };

  pi.on("model_select", (_event, ctx) => updateStatus(ctx));

  pi.on("before_provider_request", (event, ctx) => {
    const model = ctx.model;
    if (!enabled || !eligible(model)) return;
    const payload = event.payload;
    if (
      typeof payload !== "object" ||
      payload === null ||
      // Only touch top-level requests for the active model; skip payloads
      // that already carry an explicit service_tier.
      (payload as Record<string, unknown>).model !== model!.id ||
      "service_tier" in payload
    ) {
      return;
    }
    return { ...payload, service_tier: TIER_BY_API[model!.api] };
  });

  pi.registerCommand("fast", {
    description: "Toggle GPT-5.6 fast mode (faster, 2x token pricing)",
    getArgumentCompletions: (prefix) => {
      const items = ["on", "off", "status"]
        .filter((a) => a.startsWith(prefix))
        .map((a) => ({ value: a, label: a }));
      return items.length > 0 ? items : null;
    },
    handler: async (args, ctx) => {
      const arg = args.trim().toLowerCase();
      if (arg === "status") {
        // fall through to notify only
      } else if (arg === "" || arg === "on" || arg === "off") {
        enabled = arg === "" ? !enabled : arg === "on";
        updateStatus(ctx);
      } else {
        ctx.ui.notify("Usage: /fast [on|off|status]", "warning");
        return;
      }
      const name = ctx.model?.name ?? "(none)";
      ctx.ui.notify(
        !enabled
          ? `Fast mode off. Current model: ${name}.`
          : eligible(ctx.model)
            ? `Fast mode on for ${name}.`
            : `Fast mode on, but ${name} is not an eligible GPT-5.6 model.`,
        "info",
      );
    },
  });
}
