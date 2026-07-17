-- A source owns one current schedule template. Source validation in the
-- application guarantees the nullable relation not used by each source type
-- stays NULL, so these compound constraints remain unambiguous.
CREATE UNIQUE INDEX "schedule_templates_source_type_tour_package_id_key"
  ON "schedule_templates"("source_type", "tour_package_id");

CREATE UNIQUE INDEX "schedule_templates_source_type_destination_id_key"
  ON "schedule_templates"("source_type", "destination_id");
