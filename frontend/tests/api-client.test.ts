import { beforeEach, describe, expect, it, vi } from "vitest";

import { checkHealth } from "@/lib/api-client";

describe("checkHealth", () => {
  beforeEach(() => {
    vi.resetAllMocks();
  });

  it("returns status on successful response", async () => {
    global.fetch = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ status: "ok" }),
    } as Response);

    const result = await checkHealth();
    expect(result).toEqual({ status: "ok" });
  });

  it("throws on non-OK response", async () => {
    global.fetch = vi.fn().mockResolvedValue({
      ok: false,
      status: 503,
    } as Response);

    await expect(checkHealth()).rejects.toThrow("Health check failed: 503");
  });
});
