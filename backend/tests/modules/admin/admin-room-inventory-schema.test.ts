import { describe, expect, it } from "vitest";
import { adminRoomSchema } from "../../../src/modules/admin/admin.schema.js";

const validRoom = {
  name: "Deluxe Double",
  price: 1200000,
  capacity: 2,
};

describe("adminRoomSchema inventory", () => {
  it("accepts a positive whole-number inventory", () => {
    const result = adminRoomSchema.safeParse({ ...validRoom, inventory: 3 });

    expect(result.success).toBe(true);
    expect(result.data).toMatchObject({ inventory: 3 });
  });

  it.each([0, -1, 1.5])("rejects invalid inventory %s", (inventory) => {
    const result = adminRoomSchema.safeParse({ ...validRoom, inventory });

    expect(result.success).toBe(false);
  });
});
