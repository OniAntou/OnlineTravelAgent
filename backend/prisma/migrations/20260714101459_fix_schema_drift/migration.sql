/*
  Warnings:

  - The `status` column on the `trips` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `payment_status` column on the `trips` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- CreateEnum
CREATE TYPE "TripStatus" AS ENUM ('ONGOING', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'SUCCESS', 'FAILED');

-- AlterTable
ALTER TABLE "trips" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "trips" ALTER COLUMN "payment_status" DROP DEFAULT;

UPDATE "trips" SET "status" = UPPER("status");
UPDATE "trips" SET "payment_status" = UPPER("payment_status");

ALTER TABLE "trips"
  ALTER COLUMN "status" TYPE "TripStatus" USING "status"::"TripStatus",
  ALTER COLUMN "status" SET DEFAULT 'ONGOING',
  ALTER COLUMN "payment_status" TYPE "PaymentStatus" USING "payment_status"::"PaymentStatus",
  ALTER COLUMN "payment_status" SET DEFAULT 'PENDING';
