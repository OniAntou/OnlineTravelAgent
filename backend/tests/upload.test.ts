import { describe, expect, it } from "vitest";
import request from "supertest";
import { app } from "../src/app.js";

const adminAuth = `Basic ${Buffer.from("admin:test-admin_password").toString("base64")}`;

describe("upload middleware", () => {
  it("returns 400 when no file is attached", async () => {
    const res = await request(app)
      .post("/api/admin/upload")
      .set("Authorization", adminAuth);

    expect(res.status).toBe(400);
    expect(res.body.error).toBe("No file uploaded");
  });

  it("rejects unsupported file types as a client error", async () => {
    const res = await request(app)
      .post("/api/admin/upload")
      .set("Authorization", adminAuth)
      .attach("file", Buffer.from("not executable"), {
        filename: "malware.exe",
        contentType: "application/x-msdownload",
      });

    expect(res.status).toBe(400);
    expect(res.body.message).toContain("File type not allowed");
  });
});
