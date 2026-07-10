import assert from "node:assert/strict";
import test from "node:test";

import { calculateTps } from "./tps-status.ts";
import { formatDuration } from "./agent-time.ts";

test("formats live agent metrics", () => {
  assert.equal(calculateTps(24, 1_000, 3_000), 12);
  assert.equal(formatDuration(65_000), "1m 5s");
  assert.equal(formatDuration(3_665_000), "1h 1m 5s");
});
