-- Guard existing coursework data before adding constraints or converting types.
DO $preflight$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM "destinations" d
    LEFT JOIN "categories" c ON c."name" = d."category"
    WHERE c."id" IS NULL
  ) THEN
    RAISE EXCEPTION 'Cannot add destination category relation: unmatched category values exist';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM "destinations"
    WHERE "rating" IS NULL
       OR "rating" !~ '^(?:[0-4](?:\.[0-9]+)?|5(?:\.0+)?)$'
       OR "price" < 0
  ) THEN
    RAISE EXCEPTION 'Cannot harden destinations: invalid rating or price exists';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM "hotels"
    WHERE "rating" IS NULL
       OR "rating" !~ '^(?:[0-4](?:\.[0-9]+)?|5(?:\.0+)?)$'
       OR "price_from" < 0
  ) THEN
    RAISE EXCEPTION 'Cannot harden hotels: invalid rating or price exists';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM "rooms"
    WHERE "price" < 0 OR "capacity" < 1
  ) THEN
    RAISE EXCEPTION 'Cannot harden rooms: invalid price or capacity exists';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM "flights"
    WHERE "price" < 0
  ) THEN
    RAISE EXCEPTION 'Cannot harden flights: invalid price exists';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM "tour_packages"
    WHERE "price" < 0
       OR "guide_fee" < 0
       OR ("original_price" IS NOT NULL AND "original_price" < "price")
  ) THEN
    RAISE EXCEPTION 'Cannot harden tour packages: invalid monetary values exist';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM "trips"
    WHERE ("total_price" IS NOT NULL AND "total_price" < 0)
       OR ("discount" IS NOT NULL AND "discount" < 0)
       OR ("total_price" IS NOT NULL AND "discount" IS NOT NULL AND "discount" > "total_price")
  ) THEN
    RAISE EXCEPTION 'Cannot harden trips: invalid total price or discount exists';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM "promo_codes"
    WHERE "max_uses" < 0
       OR "current_uses" < 0
       OR "current_uses" > "max_uses"
       OR NOT (
         ("discount_percentage" IS NOT NULL AND "discount_amount" IS NULL AND "discount_percentage" > 0 AND "discount_percentage" <= 100)
         OR ("discount_percentage" IS NULL AND "discount_amount" IS NOT NULL AND "discount_amount" > 0)
       )
  ) THEN
    RAISE EXCEPTION 'Cannot harden promo codes: invalid discount or usage values exist';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM "reviews" r
    WHERE r."rating" NOT BETWEEN 1 AND 5
       OR r."target_type" NOT IN ('destination', 'hotel', 'tour', 'flight')
       OR (r."target_type" = 'destination' AND NOT EXISTS (SELECT 1 FROM "destinations" d WHERE d."id" = r."target_id"))
       OR (r."target_type" = 'hotel' AND NOT EXISTS (SELECT 1 FROM "hotels" h WHERE h."id" = r."target_id"))
       OR (r."target_type" = 'tour' AND NOT EXISTS (SELECT 1 FROM "tour_packages" t WHERE t."id" = r."target_id"))
       OR (r."target_type" = 'flight' AND NOT EXISTS (SELECT 1 FROM "flights" f WHERE f."id" = r."target_id"))
  ) THEN
    RAISE EXCEPTION 'Cannot harden reviews: invalid target or rating exists';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM "schedule_templates"
    WHERE NOT (
      ("source_type" = 'tour' AND "tour_package_id" IS NOT NULL AND "destination_id" IS NULL)
      OR ("source_type" = 'destination' AND "destination_id" IS NOT NULL AND "tour_package_id" IS NULL)
    )
  ) THEN
    RAISE EXCEPTION 'Cannot harden schedule templates: invalid source shape exists';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM "trips"
    WHERE "payment_method" IS NOT NULL AND "payment_txn_ref" IS NOT NULL
    GROUP BY "payment_method", "payment_txn_ref"
    HAVING COUNT(*) > 1
  ) THEN
    RAISE EXCEPTION 'Cannot add sandbox transaction reference index: duplicate values exist';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM "trips"
    WHERE "payment_method" IS NOT NULL AND "payment_txn_number" IS NOT NULL
    GROUP BY "payment_method", "payment_txn_number"
    HAVING COUNT(*) > 1
  ) THEN
    RAISE EXCEPTION 'Cannot add sandbox transaction number index: duplicate values exist';
  END IF;
END
$preflight$;

CREATE TYPE "ReviewTargetType" AS ENUM ('destination', 'hotel', 'tour', 'flight');
CREATE TYPE "ScheduleSourceType" AS ENUM ('tour', 'destination');

ALTER TABLE "reviews"
  ALTER COLUMN "target_type" TYPE "ReviewTargetType"
  USING "target_type"::text::"ReviewTargetType";

ALTER TABLE "schedule_templates"
  ALTER COLUMN "source_type" TYPE "ScheduleSourceType"
  USING "source_type"::text::"ScheduleSourceType";

ALTER TABLE "destinations"
  ADD CONSTRAINT "destinations_category_fkey"
  FOREIGN KEY ("category") REFERENCES "categories"("name")
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "destinations"
  ADD CONSTRAINT "destinations_rating_format_check"
    CHECK ("rating" ~ '^(?:[0-4](?:\.[0-9]+)?|5(?:\.0+)?)$'),
  ADD CONSTRAINT "destinations_price_nonnegative_check"
    CHECK ("price" >= 0);

ALTER TABLE "hotels"
  ADD CONSTRAINT "hotels_rating_format_check"
    CHECK ("rating" ~ '^(?:[0-4](?:\.[0-9]+)?|5(?:\.0+)?)$'),
  ADD CONSTRAINT "hotels_price_from_nonnegative_check"
    CHECK ("price_from" >= 0);

ALTER TABLE "rooms"
  ADD CONSTRAINT "rooms_price_nonnegative_check"
    CHECK ("price" >= 0),
  ADD CONSTRAINT "rooms_capacity_positive_check"
    CHECK ("capacity" >= 1);

ALTER TABLE "flights"
  ADD CONSTRAINT "flights_price_nonnegative_check"
    CHECK ("price" >= 0);

ALTER TABLE "tour_packages"
  ADD CONSTRAINT "tour_packages_price_nonnegative_check"
    CHECK ("price" >= 0),
  ADD CONSTRAINT "tour_packages_original_price_check"
    CHECK ("original_price" IS NULL OR "original_price" >= "price"),
  ADD CONSTRAINT "tour_packages_guide_fee_nonnegative_check"
    CHECK ("guide_fee" >= 0);

ALTER TABLE "trips"
  ADD CONSTRAINT "trips_total_price_nonnegative_check"
    CHECK ("total_price" IS NULL OR "total_price" >= 0),
  ADD CONSTRAINT "trips_discount_nonnegative_check"
    CHECK ("discount" IS NULL OR "discount" >= 0),
  ADD CONSTRAINT "trips_discount_not_greater_than_total_check"
    CHECK ("total_price" IS NULL OR "discount" IS NULL OR "discount" <= "total_price");

ALTER TABLE "promo_codes"
  ADD CONSTRAINT "promo_codes_max_uses_nonnegative_check"
    CHECK ("max_uses" >= 0),
  ADD CONSTRAINT "promo_codes_current_uses_range_check"
    CHECK ("current_uses" >= 0 AND "current_uses" <= "max_uses"),
  ADD CONSTRAINT "promo_codes_discount_value_check"
    CHECK (
      ("discount_percentage" IS NOT NULL AND "discount_amount" IS NULL AND "discount_percentage" > 0 AND "discount_percentage" <= 100)
      OR ("discount_percentage" IS NULL AND "discount_amount" IS NOT NULL AND "discount_amount" > 0)
    );

ALTER TABLE "reviews"
  ADD CONSTRAINT "reviews_rating_range_check"
    CHECK ("rating" BETWEEN 1 AND 5);

ALTER TABLE "schedule_templates"
  ADD CONSTRAINT "schedule_templates_source_shape_check"
    CHECK (
      ("source_type" = 'tour' AND "tour_package_id" IS NOT NULL AND "destination_id" IS NULL)
      OR ("source_type" = 'destination' AND "destination_id" IS NOT NULL AND "tour_package_id" IS NULL)
    );

-- Existing naive timestamps are UTC wall-clock values; preserve their instants explicitly.
ALTER TABLE "destinations"
  ALTER COLUMN "updated_at" TYPE TIMESTAMPTZ(3) USING "updated_at" AT TIME ZONE 'UTC';

ALTER TABLE "trips"
  ALTER COLUMN "created_at" TYPE TIMESTAMPTZ(3) USING "created_at" AT TIME ZONE 'UTC',
  ALTER COLUMN "updated_at" TYPE TIMESTAMPTZ(3) USING "updated_at" AT TIME ZONE 'UTC';

ALTER TABLE "flights"
  ALTER COLUMN "updated_at" TYPE TIMESTAMPTZ(3) USING "updated_at" AT TIME ZONE 'UTC';

ALTER TABLE "document_items"
  ALTER COLUMN "created_at" TYPE TIMESTAMPTZ(3) USING "created_at" AT TIME ZONE 'UTC',
  ALTER COLUMN "updated_at" TYPE TIMESTAMPTZ(3) USING "updated_at" AT TIME ZONE 'UTC';

ALTER TABLE "hotels"
  ALTER COLUMN "updated_at" TYPE TIMESTAMPTZ(3) USING "updated_at" AT TIME ZONE 'UTC';

ALTER TABLE "rooms"
  ALTER COLUMN "updated_at" TYPE TIMESTAMPTZ(3) USING "updated_at" AT TIME ZONE 'UTC';

ALTER TABLE "tour_packages"
  ALTER COLUMN "created_at" TYPE TIMESTAMPTZ(3) USING "created_at" AT TIME ZONE 'UTC',
  ALTER COLUMN "updated_at" TYPE TIMESTAMPTZ(3) USING "updated_at" AT TIME ZONE 'UTC';

ALTER TABLE "users"
  ALTER COLUMN "created_at" TYPE TIMESTAMPTZ(3) USING "created_at" AT TIME ZONE 'UTC',
  ALTER COLUMN "updated_at" TYPE TIMESTAMPTZ(3) USING "updated_at" AT TIME ZONE 'UTC';

ALTER TABLE "refresh_tokens"
  ALTER COLUMN "expires_at" TYPE TIMESTAMPTZ(3) USING "expires_at" AT TIME ZONE 'UTC',
  ALTER COLUMN "created_at" TYPE TIMESTAMPTZ(3) USING "created_at" AT TIME ZONE 'UTC',
  ALTER COLUMN "revoked_at" TYPE TIMESTAMPTZ(3) USING "revoked_at" AT TIME ZONE 'UTC';

ALTER TABLE "user_favorite_destinations"
  ALTER COLUMN "created_at" TYPE TIMESTAMPTZ(3) USING "created_at" AT TIME ZONE 'UTC';

ALTER TABLE "reviews"
  ALTER COLUMN "created_at" TYPE TIMESTAMPTZ(3) USING "created_at" AT TIME ZONE 'UTC',
  ALTER COLUMN "updated_at" TYPE TIMESTAMPTZ(3) USING "updated_at" AT TIME ZONE 'UTC';

ALTER TABLE "schedule_templates"
  ALTER COLUMN "created_at" TYPE TIMESTAMPTZ(3) USING "created_at" AT TIME ZONE 'UTC',
  ALTER COLUMN "updated_at" TYPE TIMESTAMPTZ(3) USING "updated_at" AT TIME ZONE 'UTC';

ALTER TABLE "trip_schedule_items"
  ALTER COLUMN "updated_at" TYPE TIMESTAMPTZ(3) USING "updated_at" AT TIME ZONE 'UTC';

ALTER TABLE "trip_schedule_updates"
  ALTER COLUMN "created_at" TYPE TIMESTAMPTZ(3) USING "created_at" AT TIME ZONE 'UTC';

ALTER TABLE "promo_codes"
  ALTER COLUMN "valid_until" TYPE TIMESTAMPTZ(3) USING "valid_until" AT TIME ZONE 'UTC',
  ALTER COLUMN "updated_at" TYPE TIMESTAMPTZ(3) USING "updated_at" AT TIME ZONE 'UTC';

CREATE UNIQUE INDEX "trips_payment_method_txn_ref_unique"
  ON "trips" ("payment_method", "payment_txn_ref")
  WHERE "payment_method" IS NOT NULL AND "payment_txn_ref" IS NOT NULL;

CREATE UNIQUE INDEX "trips_payment_method_txn_number_unique"
  ON "trips" ("payment_method", "payment_txn_number")
  WHERE "payment_method" IS NOT NULL AND "payment_txn_number" IS NOT NULL;

CREATE INDEX "trips_user_id_created_at_idx"
  ON "trips" ("user_id", "created_at" DESC);

CREATE INDEX "document_items_user_id_created_at_idx"
  ON "document_items" ("user_id", "created_at" DESC);

CREATE INDEX "reviews_target_type_target_id_created_at_idx"
  ON "reviews" ("target_type", "target_id", "created_at" DESC);

CREATE INDEX "trip_schedule_updates_trip_id_created_at_idx"
  ON "trip_schedule_updates" ("trip_id", "created_at" DESC);

CREATE INDEX "schedule_template_items_day_id_sort_order_start_time_idx"
  ON "schedule_template_items" ("day_id", "sort_order", "start_time");

CREATE INDEX "trip_schedule_items_day_id_sort_order_start_time_idx"
  ON "trip_schedule_items" ("day_id", "sort_order", "start_time");

ANALYZE "destinations";
ANALYZE "trips";
ANALYZE "flights";
ANALYZE "document_items";
ANALYZE "hotels";
ANALYZE "rooms";
ANALYZE "tour_packages";
ANALYZE "users";
ANALYZE "refresh_tokens";
ANALYZE "user_favorite_destinations";
ANALYZE "reviews";
ANALYZE "schedule_templates";
ANALYZE "trip_schedule_items";
ANALYZE "trip_schedule_updates";
ANALYZE "promo_codes";
