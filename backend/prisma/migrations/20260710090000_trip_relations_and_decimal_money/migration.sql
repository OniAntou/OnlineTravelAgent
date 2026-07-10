-- Convert money-like columns from floating point to fixed precision decimals.
ALTER TABLE "destinations" ALTER COLUMN "price" TYPE DECIMAL(12,2) USING ROUND("price"::numeric, 2);
ALTER TABLE "flights" ALTER COLUMN "price" TYPE DECIMAL(12,2) USING ROUND("price"::numeric, 2);
ALTER TABLE "hotels" ALTER COLUMN "price_from" TYPE DECIMAL(12,2) USING ROUND("price_from"::numeric, 2);
ALTER TABLE "rooms" ALTER COLUMN "price" TYPE DECIMAL(12,2) USING ROUND("price"::numeric, 2);
ALTER TABLE "tour_packages" ALTER COLUMN "price" TYPE DECIMAL(12,2) USING ROUND("price"::numeric, 2);
ALTER TABLE "tour_packages" ALTER COLUMN "original_price" TYPE DECIMAL(12,2) USING ROUND("original_price"::numeric, 2);
ALTER TABLE "tour_packages" ALTER COLUMN "guide_fee" TYPE DECIMAL(12,2) USING ROUND("guide_fee"::numeric, 2);
ALTER TABLE "tour_packages" ALTER COLUMN "guide_fee" SET DEFAULT 50.00;
ALTER TABLE "trips" ALTER COLUMN "total_price" TYPE DECIMAL(12,2) USING ROUND("total_price"::numeric, 2);
ALTER TABLE "trips" ALTER COLUMN "discount" TYPE DECIMAL(12,2) USING ROUND("discount"::numeric, 2);
ALTER TABLE "trips" ALTER COLUMN "discount" SET DEFAULT 0.00;
ALTER TABLE "promo_codes" ALTER COLUMN "discount_percentage" TYPE DECIMAL(5,2) USING ROUND("discount_percentage"::numeric, 2);
ALTER TABLE "promo_codes" ALTER COLUMN "discount_amount" TYPE DECIMAL(12,2) USING ROUND("discount_amount"::numeric, 2);

-- Add source foreign keys for trips. Nullable columns keep existing trips deployable.
ALTER TABLE "trips" ADD COLUMN "destination_id" TEXT;
ALTER TABLE "trips" ADD COLUMN "tour_package_id" TEXT;

-- Clean up stale scalar IDs before attaching foreign key constraints.
UPDATE "trips"
SET "flight_id" = NULL
WHERE "flight_id" IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM "flights" WHERE "flights"."id" = "trips"."flight_id");

UPDATE "trips"
SET "hotel_id" = NULL
WHERE "hotel_id" IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM "hotels" WHERE "hotels"."id" = "trips"."hotel_id");

UPDATE "trips"
SET "room_id" = NULL
WHERE "room_id" IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM "rooms" WHERE "rooms"."id" = "trips"."room_id");

CREATE INDEX "trips_flight_id_idx" ON "trips"("flight_id");
CREATE INDEX "trips_hotel_id_idx" ON "trips"("hotel_id");
CREATE INDEX "trips_room_id_idx" ON "trips"("room_id");
CREATE INDEX "trips_destination_id_idx" ON "trips"("destination_id");
CREATE INDEX "trips_tour_package_id_idx" ON "trips"("tour_package_id");

ALTER TABLE "trips" ADD CONSTRAINT "trips_flight_id_fkey" FOREIGN KEY ("flight_id") REFERENCES "flights"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "trips" ADD CONSTRAINT "trips_hotel_id_fkey" FOREIGN KEY ("hotel_id") REFERENCES "hotels"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "trips" ADD CONSTRAINT "trips_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "rooms"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "trips" ADD CONSTRAINT "trips_destination_id_fkey" FOREIGN KEY ("destination_id") REFERENCES "destinations"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "trips" ADD CONSTRAINT "trips_tour_package_id_fkey" FOREIGN KEY ("tour_package_id") REFERENCES "tour_packages"("id") ON DELETE SET NULL ON UPDATE CASCADE;
