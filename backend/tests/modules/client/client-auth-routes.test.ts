import { describe, expect, it } from "vitest";
import request from "supertest";
import { app } from "../../../src/app.js";

describe("client protected routes", () => {
  it("rejects a supplied invalid token on an optional-auth route", async () => {
    const res = await request(app)
      .get("/api/bootstrap")
      .set("Authorization", "Bearer invalid-token");

    expect(res.status).toBe(401);
  });

  it("requires authentication before reading a trip schedule", async () => {
    const res = await request(app).get("/api/trips/trip-1/schedule");

    expect(res.status).toBe(401);
  });

  it("requires authentication before confirming a schedule stop", async () => {
    const res = await request(app)
      .patch("/api/trips/trip-1/schedule/items/item-1/status")
      .send({ statusOverride: "completed" });

    expect(res.status).toBe(401);
  });

  it("requires authentication before reading or creating a trip change request", async () => {
    const list = await request(app).get("/api/trips/trip-1/change-requests");
    const create = await request(app)
      .post("/api/trips/trip-1/change-requests")
      .send({
        type: "REFUND",
        reason: "Tôi không thể tham gia chuyến đi này.",
      });

    expect(list.status).toBe(401);
    expect(create.status).toBe(401);
  });

  it("does not expose the retired direct-cancel endpoint", async () => {
    const response = await request(app).post("/api/trips/trip-1/cancel").send({});

    expect(response.status).toBe(404);
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
