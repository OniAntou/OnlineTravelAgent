type TripLookupClient = {
  trip: {
    findFirst(args: {
      where: { userId: string | undefined; requestId: string };
    }): Promise<unknown>;
  };
};

export function isUniqueConstraintError(error: unknown): boolean {
  return (
    typeof error === "object" &&
    error !== null &&
    "code" in error &&
    error.code === "P2002"
  );
}

export async function findIdempotentTrip<T>(
  client: TripLookupClient,
  userId: string | undefined,
  requestId?: string,
): Promise<T | null> {
  if (!requestId) return null;
  return (await client.trip.findFirst({
    where: { userId, requestId },
  })) as T | null;
}

export async function recoverIdempotentTrip<T>(
  error: unknown,
  client: TripLookupClient,
  userId: string | undefined,
  requestId?: string,
): Promise<T | null> {
  if (!requestId || !isUniqueConstraintError(error)) return null;
  return findIdempotentTrip<T>(client, userId, requestId);
}
