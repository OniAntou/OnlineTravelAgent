import request from "supertest";
import { describe, expect, it } from "vitest";
import { app } from "../../src/app.js";

describe("admin panel API origin", () => {
  it("calls the API on the same origin that serves the panel", async () => {
    const response = await request(app).get("/admin/");

    expect(response.status).toBe(200);
    expect(response.text).toContain("const API=window.location.origin;");
    expect(response.text).not.toContain("const API='http://localhost:3000';");
  });
});
