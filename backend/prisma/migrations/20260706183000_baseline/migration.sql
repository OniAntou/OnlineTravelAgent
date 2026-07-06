-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "Role" AS ENUM ('USER', 'PARTNER', 'ADMIN');

-- CreateTable
CREATE TABLE "categories" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "destinations" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "rating" TEXT NOT NULL DEFAULT '0.0',
    "duration" TEXT NOT NULL,
    "image_path" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "reviews_count" TEXT NOT NULL DEFAULT '0',
    "category" TEXT NOT NULL,
    "is_favorite" BOOLEAN NOT NULL DEFAULT false,
    "is_recommended" BOOLEAN NOT NULL DEFAULT false,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "destinations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trips" (
    "id" TEXT NOT NULL,
    "destination" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "guests" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "image_path" TEXT NOT NULL,
    "is_upcoming" BOOLEAN NOT NULL DEFAULT true,
    "flight_id" TEXT,
    "hotel_id" TEXT,
    "room_id" TEXT,
    "total_price" DOUBLE PRECISION,
    "is_custom" BOOLEAN NOT NULL DEFAULT false,
    "user_id" TEXT,
    "promo_code" TEXT,
    "discount" DOUBLE PRECISION DEFAULT 0,
    "payment_method" TEXT,
    "payment_status" TEXT DEFAULT 'pending',
    "payment_txn_ref" TEXT,
    "payment_txn_number" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "trips_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "flights" (
    "id" TEXT NOT NULL,
    "airline" TEXT NOT NULL,
    "airline_logo" TEXT NOT NULL,
    "departure" TEXT NOT NULL,
    "arrival" TEXT NOT NULL,
    "departure_time" TEXT NOT NULL,
    "arrival_time" TEXT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "duration" TEXT NOT NULL,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "flights_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "document_items" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "icon" TEXT NOT NULL,
    "color" TEXT NOT NULL,
    "user_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "document_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "hotels" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "rating" TEXT NOT NULL DEFAULT '0.0',
    "image_path" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "price_from" DOUBLE PRECISION NOT NULL,
    "address" TEXT NOT NULL,
    "amenities" TEXT[],
    "partner_id" TEXT,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "hotels_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rooms" (
    "id" TEXT NOT NULL,
    "hotel_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "capacity" INTEGER NOT NULL,
    "image_path" TEXT NOT NULL,
    "amenities" TEXT[],
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "rooms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tour_packages" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "image_path" TEXT NOT NULL,
    "duration" TEXT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "original_price" DOUBLE PRECISION,
    "destinations" TEXT[],
    "includes" TEXT[],
    "departure" TEXT NOT NULL,
    "departure_date" TEXT,
    "is_popular" BOOLEAN NOT NULL DEFAULT false,
    "includes_guide" BOOLEAN NOT NULL DEFAULT true,
    "guide_fee" DOUBLE PRECISION NOT NULL DEFAULT 50.0,
    "partner_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tour_packages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'USER',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_favorite_destinations" (
    "user_id" TEXT NOT NULL,
    "destination_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_favorite_destinations_pkey" PRIMARY KEY ("user_id","destination_id")
);

-- CreateTable
CREATE TABLE "reviews" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "target_type" TEXT NOT NULL,
    "target_id" TEXT NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reviews_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "schedule_templates" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "source_type" TEXT NOT NULL,
    "tour_package_id" TEXT,
    "destination_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "schedule_templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "schedule_template_days" (
    "id" TEXT NOT NULL,
    "template_id" TEXT NOT NULL,
    "day_number" INTEGER NOT NULL,
    "title" TEXT,

    CONSTRAINT "schedule_template_days_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "schedule_template_items" (
    "id" TEXT NOT NULL,
    "day_id" TEXT NOT NULL,
    "start_time" TEXT NOT NULL,
    "end_time" TEXT,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "location_name" TEXT,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "sort_order" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "schedule_template_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trip_schedule_days" (
    "id" TEXT NOT NULL,
    "trip_id" TEXT NOT NULL,
    "day_number" INTEGER NOT NULL,
    "date" TIMESTAMP(3),
    "title" TEXT,

    CONSTRAINT "trip_schedule_days_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trip_schedule_items" (
    "id" TEXT NOT NULL,
    "day_id" TEXT NOT NULL,
    "start_time" TEXT NOT NULL,
    "end_time" TEXT,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "location_name" TEXT,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "status_override" TEXT,
    "note" TEXT,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "trip_schedule_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trip_schedule_updates" (
    "id" TEXT NOT NULL,
    "trip_id" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "trip_schedule_updates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "promo_codes" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "discount_percentage" DOUBLE PRECISION,
    "discount_amount" DOUBLE PRECISION,
    "max_uses" INTEGER NOT NULL DEFAULT 100,
    "current_uses" INTEGER NOT NULL DEFAULT 0,
    "valid_until" TIMESTAMP(3),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "promo_codes_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "categories_name_key" ON "categories"("name");

-- CreateIndex
CREATE INDEX "destinations_category_idx" ON "destinations"("category");

-- CreateIndex
CREATE INDEX "destinations_is_recommended_idx" ON "destinations"("is_recommended");

-- CreateIndex
CREATE INDEX "trips_user_id_idx" ON "trips"("user_id");

-- CreateIndex
CREATE INDEX "trips_is_upcoming_idx" ON "trips"("is_upcoming");

-- CreateIndex
CREATE INDEX "trips_created_at_idx" ON "trips"("created_at");

-- CreateIndex
CREATE INDEX "document_items_user_id_idx" ON "document_items"("user_id");

-- CreateIndex
CREATE INDEX "hotels_location_idx" ON "hotels"("location");

-- CreateIndex
CREATE INDEX "hotels_partner_id_idx" ON "hotels"("partner_id");

-- CreateIndex
CREATE INDEX "rooms_hotel_id_idx" ON "rooms"("hotel_id");

-- CreateIndex
CREATE INDEX "tour_packages_created_at_idx" ON "tour_packages"("created_at");

-- CreateIndex
CREATE INDEX "tour_packages_partner_id_idx" ON "tour_packages"("partner_id");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "user_favorite_destinations_destination_id_idx" ON "user_favorite_destinations"("destination_id");

-- CreateIndex
CREATE INDEX "reviews_target_type_target_id_idx" ON "reviews"("target_type", "target_id");

-- CreateIndex
CREATE INDEX "reviews_user_id_idx" ON "reviews"("user_id");

-- CreateIndex
CREATE INDEX "schedule_templates_source_type_idx" ON "schedule_templates"("source_type");

-- CreateIndex
CREATE INDEX "schedule_templates_tour_package_id_idx" ON "schedule_templates"("tour_package_id");

-- CreateIndex
CREATE INDEX "schedule_templates_destination_id_idx" ON "schedule_templates"("destination_id");

-- CreateIndex
CREATE INDEX "schedule_template_days_template_id_idx" ON "schedule_template_days"("template_id");

-- CreateIndex
CREATE INDEX "schedule_template_days_day_number_idx" ON "schedule_template_days"("day_number");

-- CreateIndex
CREATE UNIQUE INDEX "schedule_template_days_template_id_day_number_key" ON "schedule_template_days"("template_id", "day_number");

-- CreateIndex
CREATE INDEX "schedule_template_items_day_id_idx" ON "schedule_template_items"("day_id");

-- CreateIndex
CREATE INDEX "schedule_template_items_sort_order_idx" ON "schedule_template_items"("sort_order");

-- CreateIndex
CREATE INDEX "trip_schedule_days_trip_id_idx" ON "trip_schedule_days"("trip_id");

-- CreateIndex
CREATE INDEX "trip_schedule_days_day_number_idx" ON "trip_schedule_days"("day_number");

-- CreateIndex
CREATE UNIQUE INDEX "trip_schedule_days_trip_id_day_number_key" ON "trip_schedule_days"("trip_id", "day_number");

-- CreateIndex
CREATE INDEX "trip_schedule_items_day_id_idx" ON "trip_schedule_items"("day_id");

-- CreateIndex
CREATE INDEX "trip_schedule_items_sort_order_idx" ON "trip_schedule_items"("sort_order");

-- CreateIndex
CREATE INDEX "trip_schedule_updates_trip_id_idx" ON "trip_schedule_updates"("trip_id");

-- CreateIndex
CREATE INDEX "trip_schedule_updates_created_at_idx" ON "trip_schedule_updates"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "promo_codes_code_key" ON "promo_codes"("code");

-- AddForeignKey
ALTER TABLE "trips" ADD CONSTRAINT "trips_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "document_items" ADD CONSTRAINT "document_items_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hotels" ADD CONSTRAINT "hotels_partner_id_fkey" FOREIGN KEY ("partner_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rooms" ADD CONSTRAINT "rooms_hotel_id_fkey" FOREIGN KEY ("hotel_id") REFERENCES "hotels"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tour_packages" ADD CONSTRAINT "tour_packages_partner_id_fkey" FOREIGN KEY ("partner_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_favorite_destinations" ADD CONSTRAINT "user_favorite_destinations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_favorite_destinations" ADD CONSTRAINT "user_favorite_destinations_destination_id_fkey" FOREIGN KEY ("destination_id") REFERENCES "destinations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "schedule_templates" ADD CONSTRAINT "schedule_templates_tour_package_id_fkey" FOREIGN KEY ("tour_package_id") REFERENCES "tour_packages"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "schedule_templates" ADD CONSTRAINT "schedule_templates_destination_id_fkey" FOREIGN KEY ("destination_id") REFERENCES "destinations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "schedule_template_days" ADD CONSTRAINT "schedule_template_days_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "schedule_templates"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "schedule_template_items" ADD CONSTRAINT "schedule_template_items_day_id_fkey" FOREIGN KEY ("day_id") REFERENCES "schedule_template_days"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trip_schedule_days" ADD CONSTRAINT "trip_schedule_days_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trip_schedule_items" ADD CONSTRAINT "trip_schedule_items_day_id_fkey" FOREIGN KEY ("day_id") REFERENCES "trip_schedule_days"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trip_schedule_updates" ADD CONSTRAINT "trip_schedule_updates_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;
