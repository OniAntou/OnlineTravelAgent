import prisma from "../config/prisma.js";
import { appCache, BOOTSTRAP_BASE_KEY } from "../config/cache.js";
import {
  applyFavoriteState,
  attachRealReviews,
  getFavoriteDestinationIds,
  normalizeCategoryName,
  orderCategoryNames,
  processTripStatus,
} from "./helpers.js";
import {
  mockCategories,
  mockDestinations,
  mockHotels,
  mockFlights,
  mockTourPackages,
  mockDocuments,
} from "../data/mock-data.js";
import { memoryDb } from "./memory-db.js";

type ReviewedDestination = Awaited<
  ReturnType<typeof attachRealReviews<{
    id: string;
    isRecommended: boolean;
    category: string;
    [key: string]: unknown;
  }>>
>[number];

type BootstrapBase = {
  categories: string[];
  destinations: ReviewedDestination[];
  hotels: Awaited<ReturnType<typeof attachRealReviews>>;
  tourPackages: Awaited<ReturnType<typeof attachRealReviews>>;
  flights: Awaited<ReturnType<typeof prisma.flight.findMany>>;
};

async function loadFromDb(): Promise<BootstrapBase | null> {
  try {
    const [categories, destinations, hotels, tourPackages, flights] = await Promise.all([
      prisma.category.findMany({ orderBy: { name: "asc" } }),
      prisma.destination.findMany(),
      prisma.hotel.findMany(),
      prisma.tourPackage.findMany({ orderBy: { createdAt: "desc" } }),
      prisma.flight.findMany(),
    ]);

    if (!destinations.length && !hotels.length && !tourPackages.length) {
      return null;
    }

    const normalizedDestinations = destinations.map((destination) => ({
      ...destination,
      category: normalizeCategoryName(destination.category),
    }));

    const [reviewedDestinations, realHotels, realTours] = await Promise.all([
      attachRealReviews(normalizedDestinations, "destination"),
      attachRealReviews(hotels, "hotel"),
      attachRealReviews(tourPackages, "tour"),
    ]);

    return {
      categories: orderCategoryNames(categories),
      destinations: reviewedDestinations,
      hotels: realHotels,
      tourPackages: realTours,
      flights,
    };
  } catch {
    return null;
  }
}

function loadMockData(): BootstrapBase {
  return {
    categories: mockCategories,
    destinations: mockDestinations as ReviewedDestination[],
    hotels: mockHotels as unknown as BootstrapBase["hotels"],
    tourPackages: mockTourPackages as unknown as BootstrapBase["tourPackages"],
    flights: mockFlights as unknown as BootstrapBase["flights"],
  };
}

export const bootstrapStore = {
  async getBootstrap(userId?: string) {
    let cachedBase = appCache.get<BootstrapBase>(BOOTSTRAP_BASE_KEY);

    if (!cachedBase) {
      const dbData = await loadFromDb();
      cachedBase = dbData ?? loadMockData();
      appCache.set(BOOTSTRAP_BASE_KEY, cachedBase);
    }

    let favoriteDestinationIds = new Set<string>();
    let trips: any[] = [];
    let documents: any[] = [];

    if (userId) {
      // Try real DB first, fall back to memory DB
      try {
        [favoriteDestinationIds, trips, documents] = await Promise.all([
          getFavoriteDestinationIds(userId),
          prisma.trip.findMany({ where: { userId }, orderBy: { createdAt: "desc" } }),
          prisma.documentItem.findMany({ where: { userId }, orderBy: { createdAt: "desc" } }),
        ]);
      } catch {
        favoriteDestinationIds = memoryDb.getFavoriteDestinationIds(userId);
        trips = memoryDb.findTripsByUserId(userId);
        documents = memoryDb.findDocumentsByUserId(userId);
        if (!documents.length) documents = mockDocuments as any;
      }
    }

    const realDestinations = applyFavoriteState(cachedBase.destinations, favoriteDestinationIds);
    const realRecommended = realDestinations.filter((d) => d.isRecommended);

    return {
      categories: cachedBase.categories,
      destinations: realDestinations,
      recommended: realRecommended,
      trips: trips.map(processTripStatus),
      documents,
      hotels: cachedBase.hotels,
      tourPackages: cachedBase.tourPackages,
      flights: cachedBase.flights,
    };
  },

  async getFavorites(userId?: string) {
    if (!userId) return [];

    try {
      const favorites = await prisma.userFavoriteDestination.findMany({
        where: { userId },
        include: { destination: true },
        orderBy: { createdAt: "desc" },
      });
      const destinations = favorites.map((favorite) => ({
        ...favorite.destination,
        isFavorite: true,
      }));
      return attachRealReviews(destinations, "destination");
    } catch {
      // Memory DB fallback
      const favIds = memoryDb.getFavoriteDestinationIds(userId);
      const allDests = mockDestinations as any[];
      const destinations = allDests
        .filter((d: any) => favIds.has(d.id))
        .map((d: any) => ({ ...d, isFavorite: true }));
      return destinations;
    }
  },

  async updateFavorite(userId: string | undefined, destinationId: string, isFavorite?: boolean) {
    if (!userId) return null;

    // Try real DB first
    try {
      const dbDest = await prisma.destination.findUnique({ where: { id: destinationId } });
      if (dbDest) {
        const existing = await prisma.userFavoriteDestination.findUnique({
          where: { userId_destinationId: { userId, destinationId } },
        });
        const newFavorite = typeof isFavorite === "boolean" ? isFavorite : !existing;

        if (newFavorite) {
          await prisma.userFavoriteDestination.upsert({
            where: { userId_destinationId: { userId, destinationId } },
            update: {},
            create: { userId, destinationId },
          });
        } else {
          await prisma.userFavoriteDestination.deleteMany({
            where: { userId, destinationId },
          });
        }

        const [withReviews] = await attachRealReviews(
          [{ ...dbDest, isFavorite: newFavorite }],
          "destination",
        );
        return withReviews;
      }
    } catch {
      // Fall through to memory DB
    }

    // Memory DB fallback
    const destinations = mockDestinations as any[];
    const destination = destinations.find((d: any) => d.id === destinationId);
    if (!destination) return null;

    const existing = memoryDb.findFavorite(userId, destinationId);
    const newFavorite = typeof isFavorite === "boolean" ? isFavorite : !existing;

    if (newFavorite) {
      memoryDb.addFavorite(userId, destinationId);
    } else {
      memoryDb.removeFavorite(userId, destinationId);
    }

    return { ...destination, isFavorite: newFavorite, rating: destination.rating || "0.0", reviewsCount: destination.reviewsCount || "0" };
  },
};
