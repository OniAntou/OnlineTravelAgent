export const SOCKET_EVENTS = {
  JOIN_TRIP_ROOM: "join_trip_room",
  LEAVE_TRIP_ROOM: "leave_trip_room",
  JOIN_TOUR_ROOM: "join_tour_room",
  LEAVE_TOUR_ROOM: "leave_tour_room",
} as const;

export const ROOM_PREFIX = {
  TRIP: "trip_",
  TOUR: "tour_",
} as const;
