-- CreateEnum
CREATE TYPE "TripChangeRequestType" AS ENUM ('RESCHEDULE', 'REFUND');

-- CreateEnum
CREATE TYPE "TripChangeRequestStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateTable
CREATE TABLE "trip_change_requests" (
    "id" TEXT NOT NULL,
    "trip_id" TEXT NOT NULL,
    "type" "TripChangeRequestType" NOT NULL,
    "status" "TripChangeRequestStatus" NOT NULL DEFAULT 'PENDING',
    "reason" TEXT NOT NULL,
    "requested_date" TEXT,
    "refund_amount" DECIMAL(12,2),
    "admin_note" TEXT,
    "reviewed_at" TIMESTAMPTZ(3),
    "created_at" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "trip_change_requests_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "trip_change_requests_trip_id_status_idx"
  ON "trip_change_requests"("trip_id", "status");

-- CreateIndex
CREATE INDEX "trip_change_requests_status_created_at_idx"
  ON "trip_change_requests"("status", "created_at");

-- Only one customer request can wait for review for each trip.
CREATE UNIQUE INDEX "trip_change_requests_one_pending_per_trip_key"
  ON "trip_change_requests" ("trip_id")
  WHERE "status" = 'PENDING';

-- AddForeignKey
ALTER TABLE "trip_change_requests"
  ADD CONSTRAINT "trip_change_requests_trip_id_fkey"
  FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- This table is accessed only through the server-side Prisma connection.
ALTER TABLE "trip_change_requests" ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
    EXECUTE 'REVOKE ALL ON TABLE "trip_change_requests" FROM anon';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
    EXECUTE 'REVOKE ALL ON TABLE "trip_change_requests" FROM authenticated';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
    EXECUTE 'REVOKE ALL ON TABLE "trip_change_requests" FROM service_role';
  END IF;
END
$$;
