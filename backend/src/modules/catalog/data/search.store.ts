import prisma from "../../../infrastructure/database/prisma.js";
import { attachRealReviews, formatSearchQuery } from "../../../core/data/store-helpers.js";
import { mockHotels, mockTourPackages, mockDestinations } from "../../../infrastructure/fallback/mock-data.js";
import { assertMemoryFallbackEnabled } from "../../../core/config/data-availability.js";

export const searchStore = {
  async globalSearch(query: string) {
    if (!query.trim()) return { hotels: [], tours: [], destinations: [] };
    try {
      const formattedQuery = formatSearchQuery(query) || "no_searchable_tokens";
      const [hotels, tours, destinations] = await Promise.all([
        prisma.hotel.findMany({
          where: {
            OR: [
              { name: { search: formattedQuery } },
              { location: { search: formattedQuery } },
              { name: { contains: query, mode: "insensitive" } },
            ],
          },
          take: 5,
        }),
        prisma.tourPackage.findMany({
          where: {
            OR: [
              { name: { search: formattedQuery } },
              { description: { search: formattedQuery } },
              { departure: { search: formattedQuery } },
              { name: { contains: query, mode: "insensitive" } },
            ],
          },
          take: 5,
        }),
        prisma.destination.findMany({
          where: {
            OR: [
              { name: { search: formattedQuery } },
              { location: { search: formattedQuery } },
              { name: { contains: query, mode: "insensitive" } },
            ],
          },
          take: 5,
        }),
      ]);

      return {
        hotels: await attachRealReviews(hotels, "hotel"),
        tours: await attachRealReviews(tours, "tour"),
        destinations: await attachRealReviews(destinations, "destination"),
      };
    } catch {
      assertMemoryFallbackEnabled();
      const q = query.toLowerCase();
      const filterByName = <T extends { name: string }>(items: T[]) =>
        items.filter((i) => i.name.toLowerCase().includes(q));
      return {
        hotels: filterByName(mockHotels),
        tours: filterByName(mockTourPackages),
        destinations: filterByName(mockDestinations),
      };
    }
  },
};
