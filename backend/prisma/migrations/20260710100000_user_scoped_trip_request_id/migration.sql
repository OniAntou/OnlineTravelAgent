-- Make idempotency keys private to each booking owner. `IF NOT EXISTS` keeps
-- databases created from the older baseline (which lacked this column) deployable.
ALTER TABLE "trips" ADD COLUMN IF NOT EXISTS "request_id" TEXT;
DROP INDEX IF EXISTS "trips_request_id_key";
CREATE UNIQUE INDEX IF NOT EXISTS "trips_user_id_request_id_key"
  ON "trips"("user_id", "request_id");