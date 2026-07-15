import { bootstrapStore } from "./bootstrap.store.js";
import { documentStore } from "./document.store.js";
import { hotelStore } from "../../catalog/data/hotel.store.js";
import { promoStore } from "../../catalog/data/promo.store.js";
import { reviewStore } from "../../catalog/data/review.store.js";
import { searchStore } from "../../catalog/data/search.store.js";
import { tourStore } from "../../catalog/data/tour.store.js";
import { tripStore } from "../../trips/data/trip.store.js";

export const store = {
  ...bootstrapStore,
  ...tripStore,
  ...hotelStore,
  ...tourStore,
  ...reviewStore,
  ...documentStore,
  ...searchStore,
  ...promoStore,
};
