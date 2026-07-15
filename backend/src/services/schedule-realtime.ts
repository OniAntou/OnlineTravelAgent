export type ScheduleTemplateRealtimeSource = {
  sourceType?: string | null;
  tourPackageId?: string | null;
};

export type TourScheduleRealtimeTarget = {
  room: string;
  payload: { tourId: string };
};

export function getTourScheduleRealtimeTarget(
  template: ScheduleTemplateRealtimeSource | null | undefined,
): TourScheduleRealtimeTarget | null {
  if (template?.sourceType !== "tour" || !template.tourPackageId) {
    return null;
  }

  return {
    room: `tour_${template.tourPackageId}`,
    payload: { tourId: template.tourPackageId },
  };
}
