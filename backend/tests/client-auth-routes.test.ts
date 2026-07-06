import { describe, expect, it } from "vitest";
import request from "supertest";
import { app } from "../src/app.js";

describe("client protected routes", () => {
  it("requires authentication before reading a trip schedule", async () => {
    const res = await request(app).get("/api/trips/trip-1/schedule");

    expect(res.status).toBe(401);
  });

  it("requires authentication for client documents", async () => {
    const list = await request(app).get("/api/documents");
    const create = await request(app).post("/api/documents").send({
      title: "Passport",
      description: "Passport scan",
      icon: "fa-file",
      color: "text-blue-500",
    });
    const remove = await request(app).delete("/api/documents/doc-1");

    expect(list.status).toBe(401);
    expect(create.status).toBe(401);
    expect(remove.status).toBe(401);
  });
});
