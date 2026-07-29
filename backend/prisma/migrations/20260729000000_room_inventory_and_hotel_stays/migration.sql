ALTER TABLE "rooms" ADD COLUMN "inventory" INTEGER NOT NULL DEFAULT 1;

ALTER TABLE "trips" ADD COLUMN "hotel_check_in" TIMESTAMPTZ(3);
ALTER TABLE "trips" ADD COLUMN "hotel_check_out" TIMESTAMPTZ(3);

ALTER TABLE "rooms"
  ADD CONSTRAINT "rooms_inventory_positive" CHECK ("inventory" > 0);

ALTER TABLE "trips"
  ADD CONSTRAINT "trips_hotel_stay_complete"
  CHECK (
    ("hotel_check_in" IS NULL AND "hotel_check_out" IS NULL)
    OR (
      "hotel_check_in" IS NOT NULL
      AND "hotel_check_out" IS NOT NULL
      AND "hotel_check_out" > "hotel_check_in"
    )
  );

CREATE INDEX "trips_room_stay_overlap_idx"
  ON "trips" ("room_id", "hotel_check_in", "hotel_check_out")
  WHERE "room_id" IS NOT NULL AND "status" <> 'CANCELLED';
