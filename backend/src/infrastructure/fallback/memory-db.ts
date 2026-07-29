import crypto from "crypto";

// ---------------------------------------------------------------------------
// In-memory database that mirrors the subset of Prisma models the app needs.
// Activated automatically when PostgreSQL is unreachable.
// Data resets on server restart.
// ---------------------------------------------------------------------------

export interface MemUser {
  id: string;
  name: string;
  email: string;
  password: string;
  role: "USER" | "PARTNER" | "ADMIN";
  createdAt: Date;
  updatedAt: Date;
}

export interface MemRefreshToken {
  id: string;
  userId: string;
  tokenHash: string;
  expiresAt: Date;
  createdAt: Date;
  revokedAt: Date | null;
}

export interface MemTrip {
  id: string;
  userId?: string | null;
  destination: string;
  location: string;
  date: string;
  guests: string;
  status: "PENDING" | "ONGOING" | "COMPLETED" | "CANCELLED";
  imagePath: string;
  isUpcoming: boolean;
  flightId?: string | null;
  hotelId?: string | null;
  roomId?: string | null;
  hotelCheckIn?: Date | null;
  hotelCheckOut?: Date | null;
  totalPrice?: number | null;
  isCustom: boolean;
  requestId?: string | null;
  promoCode?: string | null;
  discount?: number | null;
  paymentMethod?: string | null;
  paymentStatus?: "PENDING" | "SUCCESS" | "FAILED" | null;
  paymentTxnRef?: string | null;
  paymentTxnNumber?: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface MemTripChangeRequest {
  id: string;
  tripId: string;
  type: "RESCHEDULE" | "REFUND";
  status: "PENDING" | "APPROVED" | "REJECTED";
  reason: string;
  requestedDate?: string | null;
  refundAmount?: number | null;
  adminNote?: string | null;
  reviewedAt?: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface MemReview {
  id: string;
  userId: string;
  targetType: string;
  targetId: string;
  rating: number;
  comment: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface MemDocument {
  id: string;
  title: string;
  description: string;
  icon: string;
  color: string;
  userId?: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface MemFavorite {
  userId: string;
  destinationId: string;
  createdAt: Date;
}

class MemoryDB {
  users: MemUser[] = [];
  refreshTokens: MemRefreshToken[] = [];
  trips: MemTrip[] = [];
  tripChangeRequests: MemTripChangeRequest[] = [];
  reviews: MemReview[] = [];
  documents: MemDocument[] = [];
  favorites: MemFavorite[] = [];
  initialized = false;

  init() {
    if (this.initialized) return;
    this.initialized = true;

    // Seed a default admin user
    const adminId = crypto.randomUUID();
    this.users.push({
      id: adminId,
      name: "Admin",
      email: "admin@example.com",
      // bcrypt hash of "admin123" — will be stored as-is for simplicity
      password: "$2b$10$YQ8GvPfqz5VYR1dK1Z5KqOiCmBvYpJ5kX9vX8mZ3nO2tU6wL4rS2e",
      role: "ADMIN",
      createdAt: new Date(),
      updatedAt: new Date(),
    });
  }

  // ---- Users ----

  findUserByEmail(email: string) {
    return this.users.find((u) => u.email === email) || null;
  }

  findUserById(id: string) {
    return this.users.find((u) => u.id === id) || null;
  }

  createUser(data: { name: string; email: string; password: string; role?: MemUser["role"] }) {
    const now = new Date();
    const user: MemUser = {
      id: crypto.randomUUID(),
      name: data.name,
      email: data.email,
      password: data.password,
      role: data.role || "USER",
      createdAt: now,
      updatedAt: now,
    };
    this.users.push(user);
    return user;
  }

  updateUser(id: string, data: Partial<Pick<MemUser, "role" | "password" | "name">>) {
    const user = this.users.find((u) => u.id === id);
    if (!user) return null;
    if (data.role !== undefined) user.role = data.role;
    if (data.password !== undefined) user.password = data.password;
    if (data.name !== undefined) user.name = data.name;
    user.updatedAt = new Date();
    return user;
  }

  // ---- Refresh Tokens ----

  createRefreshToken(userId: string, tokenHash: string, expiresAt: Date) {
    const token: MemRefreshToken = {
      id: crypto.randomUUID(),
      userId,
      tokenHash,
      expiresAt,
      createdAt: new Date(),
      revokedAt: null,
    };
    this.refreshTokens.push(token);
    return token;
  }

  findRefreshToken(tokenHash: string) {
    return this.refreshTokens.find((t) => t.tokenHash === tokenHash) || null;
  }

  revokeRefreshToken(tokenHash: string) {
    const token = this.refreshTokens.find((t) => t.tokenHash === tokenHash);
    if (token) token.revokedAt = new Date();
    return !!token;
  }

  revokeAllRefreshTokens(userId: string) {
    for (const t of this.refreshTokens) {
      if (t.userId === userId && !t.revokedAt) t.revokedAt = new Date();
    }
  }

  // ---- Trips ----

  createTrip(data: Omit<MemTrip, "createdAt" | "updatedAt">) {
    const now = new Date();
    const trip: MemTrip = { ...data, createdAt: now, updatedAt: now };
    this.trips.push(trip);
    return trip;
  }

  findTripById(id: string) {
    return this.trips.find((t) => t.id === id) || null;
  }

  findTripByRequestId(userId: string | undefined, requestId: string) {
    return this.trips.find((t) => t.userId === userId && t.requestId === requestId) || null;
  }

  findTripsByUserId(userId: string, type?: string) {
    let trips = this.trips.filter((t) => t.userId === userId);
    if (type === "upcoming") trips = trips.filter((t) => t.isUpcoming);
    if (type === "past") trips = trips.filter((t) => !t.isUpcoming);
    return [...trips].sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  }

  updateTrip(id: string, data: Partial<MemTrip>) {
    const trip = this.trips.find((t) => t.id === id);
    if (!trip) return null;
    Object.assign(trip, data, { updatedAt: new Date() });
    return trip;
  }

  countActiveHotelStayOverlaps(roomId: string, checkIn: Date, checkOut: Date) {
    return this.trips.filter((trip) =>
      trip.roomId === roomId
      && trip.status !== "CANCELLED"
      && trip.hotelCheckIn instanceof Date
      && trip.hotelCheckOut instanceof Date
      && trip.hotelCheckIn < checkOut
      && trip.hotelCheckOut > checkIn,
    ).length;
  }

  // ---- Trip Change Requests ----

  createTripChangeRequest(
    data: Omit<MemTripChangeRequest, "id" | "createdAt" | "updatedAt"> & {
      id?: string;
    },
  ) {
    const now = new Date();
    const request: MemTripChangeRequest = {
      ...data,
      id: data.id ?? crypto.randomUUID(),
      createdAt: now,
      updatedAt: now,
    };
    this.tripChangeRequests.push(request);
    return request;
  }

  findTripChangeRequestById(id: string) {
    return this.tripChangeRequests.find((request) => request.id === id) ?? null;
  }

  findTripChangeRequestsByTripId(tripId: string) {
    return this.tripChangeRequests
      .filter((request) => request.tripId === tripId)
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  }

  findPendingTripChangeRequest(tripId: string) {
    return this.tripChangeRequests.find(
      (request) => request.tripId === tripId && request.status === "PENDING",
    ) ?? null;
  }

  updateTripChangeRequest(id: string, data: Partial<MemTripChangeRequest>) {
    const request = this.tripChangeRequests.find((item) => item.id === id);
    if (!request) return null;
    Object.assign(request, data, { updatedAt: new Date() });
    return request;
  }

  // ---- Reviews ----

  findReviews(targetType: string, targetId: string) {
    return this.reviews
      .filter((r) => r.targetType === targetType && r.targetId === targetId)
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  }

  upsertReview(userId: string, targetType: string, targetId: string, rating: number, comment: string) {
    const existing = this.reviews.find(
      (r) => r.userId === userId && r.targetType === targetType && r.targetId === targetId,
    );
    if (existing) {
      existing.rating = rating;
      existing.comment = comment;
      existing.updatedAt = new Date();
      return existing;
    }
    const review: MemReview = {
      id: crypto.randomUUID(),
      userId,
      targetType,
      targetId,
      rating,
      comment,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    this.reviews.push(review);
    return review;
  }

  deleteReview(userId: string, reviewId: string) {
    const idx = this.reviews.findIndex((r) => r.id === reviewId && r.userId === userId);
    if (idx === -1) return false;
    this.reviews.splice(idx, 1);
    return true;
  }

  // ---- Documents ----

  findDocumentsByUserId(userId: string) {
    return this.documents
      .filter((d) => d.userId === userId)
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  }

  createDocument(data: Omit<MemDocument, "createdAt" | "updatedAt">) {
    const now = new Date();
    const doc: MemDocument = { ...data, createdAt: now, updatedAt: now };
    this.documents.push(doc);
    return doc;
  }

  deleteDocument(userId: string, id: string) {
    const idx = this.documents.findIndex((d) => d.id === id && d.userId === userId);
    if (idx === -1) return false;
    this.documents.splice(idx, 1);
    return true;
  }

  // ---- Favorites ----

  getFavoriteDestinationIds(userId: string) {
    return new Set(this.favorites.filter((f) => f.userId === userId).map((f) => f.destinationId));
  }

  findFavorite(userId: string, destinationId: string) {
    return this.favorites.find((f) => f.userId === userId && f.destinationId === destinationId) || null;
  }

  addFavorite(userId: string, destinationId: string) {
    if (!this.findFavorite(userId, destinationId)) {
      this.favorites.push({ userId, destinationId, createdAt: new Date() });
    }
  }

  removeFavorite(userId: string, destinationId: string) {
    const idx = this.favorites.findIndex((f) => f.userId === userId && f.destinationId === destinationId);
    if (idx !== -1) this.favorites.splice(idx, 1);
  }
}

export const memoryDb = new MemoryDB();
