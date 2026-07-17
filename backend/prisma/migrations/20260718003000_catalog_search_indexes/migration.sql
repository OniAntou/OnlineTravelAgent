-- Keep the existing Prisma full-text filters and ILIKE fallback index-backed.
-- `english` matches Prisma's PostgreSQL full-text-search configuration.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX "hotels_name_fts_idx"
  ON "hotels" USING GIN (to_tsvector('english', "name"));
CREATE INDEX "hotels_location_fts_idx"
  ON "hotels" USING GIN (to_tsvector('english', "location"));
CREATE INDEX "hotels_name_trgm_idx"
  ON "hotels" USING GIN ("name" gin_trgm_ops);

CREATE INDEX "tour_packages_name_fts_idx"
  ON "tour_packages" USING GIN (to_tsvector('english', "name"));
CREATE INDEX "tour_packages_description_fts_idx"
  ON "tour_packages" USING GIN (to_tsvector('english', "description"));
CREATE INDEX "tour_packages_departure_fts_idx"
  ON "tour_packages" USING GIN (to_tsvector('english', "departure"));
CREATE INDEX "tour_packages_name_trgm_idx"
  ON "tour_packages" USING GIN ("name" gin_trgm_ops);

CREATE INDEX "destinations_name_fts_idx"
  ON "destinations" USING GIN (to_tsvector('english', "name"));
CREATE INDEX "destinations_location_fts_idx"
  ON "destinations" USING GIN (to_tsvector('english', "location"));
CREATE INDEX "destinations_name_trgm_idx"
  ON "destinations" USING GIN ("name" gin_trgm_ops);
