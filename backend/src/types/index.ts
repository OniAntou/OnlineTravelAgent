export interface CreateDestinationBody {
  id?: string;
  name: string;
  location: string;
  category?: string;
  rating?: string;
  duration?: string;
  imagePath?: string;
  description?: string;
  price?: number;
  reviewsCount?: string;
  isFavorite?: boolean;
  isRecommended?: boolean;
  latitude?: number;
  longitude?: number;
}

export interface UpdateDestinationBody extends Partial<CreateDestinationBody> {}

export interface CreateHotelBody {
  id?: string;
  name: string;
  location: string;
  address?: string;
  rating?: string;
  imagePath?: string;
  description?: string;
  priceFrom?: number;
  amenities?: string[];
  latitude?: number;
  longitude?: number;
}

export interface UpdateHotelBody extends Partial<CreateHotelBody> {}

export interface CreateFlightBody {
  id?: string;
  airline: string;
  airlineLogo?: string;
  departure: string;
  arrival: string;
  departureTime?: string;
  arrivalTime?: string;
  price?: number;
  duration?: string;
}

export interface UpdateFlightBody extends Partial<CreateFlightBody> {}

export interface CreateTourBody {
  id?: string;
  name: string;
  description?: string;
  imagePath?: string;
  duration?: string;
  price?: number;
  originalPrice?: number;
  destinations?: string[];
  includes?: string[];
  departure?: string;
  departureDate?: string;
  isPopular?: boolean;
  includesGuide?: boolean;
  guideFee?: number;
}

export interface UpdateTourBody extends Partial<CreateTourBody> {}

export interface CreateRoomBody {
  id?: string;
  name: string;
  description?: string;
  price: number;
  capacity: number;
  imagePath?: string;
  amenities?: string[];
}

export interface UpdateRoomBody extends Partial<CreateRoomBody> {}

export interface CreateDocumentBody {
  id?: string;
  title: string;
  description?: string;
  icon?: string;
  color?: string;
}

export interface UpdateDocumentBody extends Partial<CreateDocumentBody> {}

export interface CreateCategoryBody {
  name: string;
}

export interface CreateUserBody {
  name: string;
  email: string;
  password: string;
}

export interface UpdateTripBody {
  status?: string;
  isUpcoming?: boolean;
}

export interface BookTripBody {
  destinationId: string;
  date?: string;
  guests?: string;
  totalPrice?: number;
}

export interface BookFlightBody {
  flightId: string;
  date: string;
  guests: string;
}

export interface BookHotelBody {
  roomId: string;
  checkIn: string;
  checkOut: string;
  guests: string;
}

export interface BookTourBody {
  tourId: string;
  date: string;
  guests: string;
  totalPrice?: number;
}

export interface CreateReviewBody {
  targetType: string;
  targetId: string;
  rating: number;
  comment: string;
}

export interface UpdateScheduleItemBody {
  startTime?: string;
  endTime?: string | null;
  title?: string;
  description?: string | null;
  locationName?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  sortOrder?: number;
  statusOverride?: string | null;
  note?: string | null;
}

export interface CreateScheduleItemBody {
  dayId: string;
  startTime: string;
  endTime?: string | null;
  title: string;
  description?: string | null;
  locationName?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  sortOrder?: number;
}

export interface CreateScheduleDayBody {
  dayNumber: number;
  title?: string | null;
}

export interface UpdateScheduleDayBody {
  title?: string | null;
}

export interface CreateScheduleUpdateBody {
  message: string;
}
