import {
  Prisma,
  ScheduleSourceType as PrismaScheduleSourceType,
} from "@prisma/client";
import prisma from "../../infrastructure/database/prisma.js";
import { parseDateOnly } from "../../core/data/store-helpers.js";

export type ScheduleSourceType = PrismaScheduleSourceType;

export type ScheduleItemInput = {
  id?: string;
  startTime: string;
  endTime?: string | null;
  title: string;
  description?: string | null;
  locationName?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  sortOrder?: number;
  statusOverride?: string | null;
  note?: string | null;
};

export type ScheduleDayInput = {
  id?: string;
  dayNumber: number;
  date?: string | null;
  title?: string | null;
  items?: ScheduleItemInput[];
};

export type ScheduleTemplateInput = {
  id?: string;
  name: string;
  sourceType: ScheduleSourceType;
  tourPackageId?: string | null;
  destinationId?: string | null;
  days?: ScheduleDayInput[];
};

type CopyTemplateParams = {
  tripId: string;
  sourceType: ScheduleSourceType;
  sourceId: string;
  tripDate?: string | null;
};

async function copyTemplateToTripWithClient(
  tx: Prisma.TransactionClient,
  params: CopyTemplateParams,
) {
  const existing = await tx.tripScheduleDay.count({
    where: { tripId: params.tripId },
  });
  if (existing > 0) return;

  const template = await tx.scheduleTemplate.findUnique({
    where:
      params.sourceType === PrismaScheduleSourceType.tour
        ? {
            sourceType_tourPackageId: {
              sourceType: PrismaScheduleSourceType.tour,
              tourPackageId: params.sourceId,
            },
          }
        : {
            sourceType_destinationId: {
              sourceType: PrismaScheduleSourceType.destination,
              destinationId: params.sourceId,
            },
          },
    include: {
      days: {
        orderBy: { dayNumber: "asc" },
        include: {
          items: { orderBy: [{ sortOrder: "asc" }, { startTime: "asc" }] },
        },
      },
    },
  });
  if (!template) return;

  const startDate = parseTripStartDate(params.tripDate);
  for (const day of template.days) {
    await tx.tripScheduleDay.create({
      data: {
        tripId: params.tripId,
        dayNumber: day.dayNumber,
        date: startDate ? addDays(startDate, day.dayNumber - 1) : null,
        title: day.title,
        items: {
          create: day.items.map((item) => ({
            startTime: item.startTime,
            endTime: item.endTime,
            title: item.title,
            description: item.description,
            locationName: item.locationName,
            latitude: item.latitude,
            longitude: item.longitude,
            sortOrder: item.sortOrder,
          })),
        },
      },
    });
  }
}

const allowedOverrides = new Set([
  "completed",
  "ongoing",
  "upcoming",
  "cancelled",
  "delayed",
]);

function isClockTime(value: string): boolean {
  return /^([01]\d|2[0-3]):[0-5]\d$/.test(value);
}

function assertClockTime(value: string, field: string) {
  if (!isClockTime(value)) {
    throw new Error(`${field} must use HH:mm format`);
  }
}

function assertSource(input: ScheduleTemplateInput) {
  const hasTour = Boolean(input.tourPackageId);
  const hasDestination = Boolean(input.destinationId);
  if (
    input.sourceType === PrismaScheduleSourceType.tour &&
    (!hasTour || hasDestination)
  ) {
    throw new Error("tour template requires tourPackageId only");
  }
  if (
    input.sourceType === PrismaScheduleSourceType.destination &&
    (!hasDestination || hasTour)
  ) {
    throw new Error("destination template requires destinationId only");
  }
}

function normalizeSortOrder(item: ScheduleItemInput, index: number): number {
  return typeof item.sortOrder === "number" ? item.sortOrder : index;
}

function toNullableDate(value?: string | null): Date | null {
  if (!value) return null;
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

export function parseTripStartDate(value?: string | null): Date | null {
  if (!value) return null;
  return parseDateOnly(value.split(/\s+-\s+/, 1)[0] ?? "");
}

function addDays(date: Date, days: number): Date {
  const result = new Date(date);
  result.setUTCDate(result.getUTCDate() + days);
  return result;
}

function groupByTripId<T extends { tripId: string }>(records: T[]): Map<string, T[]> {
  const groups = new Map<string, T[]>();
  for (const record of records) {
    const group = groups.get(record.tripId);
    if (group) {
      group.push(record);
    } else {
      groups.set(record.tripId, [record]);
    }
  }
  return groups;
}

function assertItems(days: ScheduleDayInput[] = []) {
  for (const day of days) {
    if (!Number.isInteger(day.dayNumber) || day.dayNumber < 1) {
      throw new Error("dayNumber must be a positive integer");
    }
    for (const item of day.items ?? []) {
      assertClockTime(item.startTime, "startTime");
      if (item.endTime) assertClockTime(item.endTime, "endTime");
      if (!item.title?.trim()) {
        throw new Error("schedule item title is required");
      }
      if (item.statusOverride && !allowedOverrides.has(item.statusOverride)) {
        throw new Error("invalid schedule item statusOverride");
      }
    }
  }
}

async function createTemplateDays(
  tx: Prisma.TransactionClient,
  templateId: string,
  days: ScheduleDayInput[] = [],
) {
  for (const day of days) {
    await tx.scheduleTemplateDay.create({
      data: {
        templateId,
        dayNumber: day.dayNumber,
        title: day.title ?? null,
        items: {
          create: (day.items ?? []).map((item, index) => ({
            startTime: item.startTime,
            endTime: item.endTime ?? null,
            title: item.title,
            description: item.description ?? null,
            locationName: item.locationName ?? null,
            latitude: item.latitude ?? null,
            longitude: item.longitude ?? null,
            sortOrder: normalizeSortOrder(item, index),
          })),
        },
      },
    });
  }
}

async function createTripDays(
  tx: Prisma.TransactionClient,
  tripId: string,
  days: ScheduleDayInput[] = [],
) {
  for (const day of days) {
    await tx.tripScheduleDay.create({
      data: {
        tripId,
        dayNumber: day.dayNumber,
        date: toNullableDate(day.date),
        title: day.title ?? null,
        items: {
          create: (day.items ?? []).map((item, index) => ({
            startTime: item.startTime,
            endTime: item.endTime ?? null,
            title: item.title,
            description: item.description ?? null,
            locationName: item.locationName ?? null,
            latitude: item.latitude ?? null,
            longitude: item.longitude ?? null,
            sortOrder: normalizeSortOrder(item, index),
            statusOverride: item.statusOverride ?? null,
            note: item.note ?? null,
          })),
        },
      },
    });
  }
}

export const scheduleService = {
  async getScheduleTemplates() {
    return prisma.scheduleTemplate.findMany({
      include: {
        days: {
          orderBy: { dayNumber: "asc" },
          include: {
            items: { orderBy: [{ sortOrder: "asc" }, { startTime: "asc" }] },
          },
        },
      },
      orderBy: { updatedAt: "desc" },
    });
  },

  async createScheduleTemplate(input: ScheduleTemplateInput) {
    assertSource(input);
    assertItems(input.days);

    return prisma.$transaction(async (tx) => {
      const template = await tx.scheduleTemplate.create({
        data: {
          id: input.id,
          name: input.name,
          sourceType: input.sourceType,
          tourPackageId: input.tourPackageId ?? null,
          destinationId: input.destinationId ?? null,
        },
      });
      await createTemplateDays(tx, template.id, input.days);
      return tx.scheduleTemplate.findUnique({
        where: { id: template.id },
        include: {
          days: {
            orderBy: { dayNumber: "asc" },
            include: {
              items: { orderBy: [{ sortOrder: "asc" }, { startTime: "asc" }] },
            },
          },
        },
      });
    });
  },

  async updateScheduleTemplate(id: string, input: ScheduleTemplateInput) {
    assertSource(input);
    assertItems(input.days);

    return prisma.$transaction(async (tx) => {
      await tx.scheduleTemplateItem.deleteMany({
        where: { day: { templateId: id } },
      });
      await tx.scheduleTemplateDay.deleteMany({ where: { templateId: id } });
      await tx.scheduleTemplate.update({
        where: { id },
        data: {
          name: input.name,
          sourceType: input.sourceType,
          tourPackageId: input.tourPackageId ?? null,
          destinationId: input.destinationId ?? null,
        },
      });
      await createTemplateDays(tx, id, input.days);
      return tx.scheduleTemplate.findUnique({
        where: { id },
        include: {
          days: {
            orderBy: { dayNumber: "asc" },
            include: {
              items: { orderBy: [{ sortOrder: "asc" }, { startTime: "asc" }] },
            },
          },
        },
      });
    });
  },

  async deleteScheduleTemplate(id: string) {
    await prisma.scheduleTemplate.delete({ where: { id } });
    return { ok: true };
  },

  async copyTemplateToTrip(
    params: CopyTemplateParams,
    transaction?: Prisma.TransactionClient,
  ) {
    if (transaction) {
      return copyTemplateToTripWithClient(transaction, params);
    }
    return prisma.$transaction((tx) => copyTemplateToTripWithClient(tx, params));
  },

  async getTripSchedule(tripId: string, requesterUserId?: string) {
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
      select: { id: true, userId: true },
    });
    if (!trip) return null;
    if (requesterUserId !== undefined && trip.userId !== requesterUserId)
      return null;

    const [days, updates] = await Promise.all([
      prisma.tripScheduleDay.findMany({
        where: { tripId },
        orderBy: { dayNumber: "asc" },
        include: {
          items: { orderBy: [{ sortOrder: "asc" }, { startTime: "asc" }] },
        },
      }),
      prisma.tripScheduleUpdate.findMany({
        where: { tripId },
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return { tripId, days, updates };
  },

  async getTripSchedulesBatch(tripIds: string[], requesterUserId: string) {
    const uniqueIds = [...new Set(tripIds)];
    const trips = await prisma.trip.findMany({
      where: { id: { in: uniqueIds }, userId: requesterUserId },
      select: { id: true },
    });
    const ownedIds = trips.map((trip) => trip.id);
    if (!ownedIds.length) return {};

    const [allDays, allUpdates] = await Promise.all([
      prisma.tripScheduleDay.findMany({
        where: { tripId: { in: ownedIds } },
        orderBy: { dayNumber: "asc" },
        include: {
          items: { orderBy: [{ sortOrder: "asc" }, { startTime: "asc" }] },
        },
      }),
      prisma.tripScheduleUpdate.findMany({
        where: { tripId: { in: ownedIds } },
        orderBy: { createdAt: "desc" },
      }),
    ]);

    const result: Record<
      string,
      { tripId: string; days: typeof allDays; updates: typeof allUpdates }
    > = {};
    const daysByTrip = groupByTripId(allDays);
    const updatesByTrip = groupByTripId(allUpdates);
    for (const tripId of ownedIds) {
      result[tripId] = {
        tripId,
        days: daysByTrip.get(tripId) ?? [],
        updates: updatesByTrip.get(tripId) ?? [],
      };
    }
    return result;
  },

  async confirmTripScheduleItem(
    tripId: string,
    itemId: string,
    requesterUserId: string,
  ) {
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
      select: { id: true, userId: true },
    });
    if (!trip || trip.userId !== requesterUserId) return null;

    const item = await prisma.tripScheduleItem.findFirst({
      where: { id: itemId, day: { tripId } },
      select: { id: true },
    });
    if (!item) return null;

    return prisma.tripScheduleItem.update({
      where: { id: item.id },
      data: { statusOverride: "completed" },
    });
  },

  async updateTripSchedule(tripId: string, days: ScheduleDayInput[] = []) {
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
      select: { id: true },
    });
    if (!trip) return null;
    assertItems(days);

    return prisma.$transaction(async (tx) => {
      await tx.tripScheduleItem.deleteMany({ where: { day: { tripId } } });
      await tx.tripScheduleDay.deleteMany({ where: { tripId } });
      await createTripDays(tx, tripId, days);
      const savedDays = await tx.tripScheduleDay.findMany({
        where: { tripId },
        orderBy: { dayNumber: "asc" },
        include: {
          items: { orderBy: [{ sortOrder: "asc" }, { startTime: "asc" }] },
        },
      });
      const updates = await tx.tripScheduleUpdate.findMany({
        where: { tripId },
        orderBy: { createdAt: "desc" },
      });
      return { tripId, days: savedDays, updates };
    });
  },

  async createTripScheduleUpdate(tripId: string, message: string) {
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
      select: { id: true },
    });
    if (!trip) return null;
    return prisma.tripScheduleUpdate.create({
      data: { tripId, message },
    });
  },

  async deleteTripScheduleUpdate(tripId: string, updateId: string) {
    await prisma.tripScheduleUpdate.delete({
      where: { id: updateId, tripId },
    });
    return { ok: true };
  },

  async addTripScheduleItem(
    tripId: string,
    input: ScheduleItemInput & { dayId: string },
  ) {
    const day = await prisma.tripScheduleDay.findFirst({
      where: { id: input.dayId, tripId },
    });
    if (!day) return null;
    assertClockTime(input.startTime, "startTime");
    if (input.endTime) assertClockTime(input.endTime, "endTime");
    if (!input.title?.trim()) throw new Error("title is required");
    if (input.statusOverride && !allowedOverrides.has(input.statusOverride)) {
      throw new Error("invalid schedule item statusOverride");
    }

    const maxSort = await prisma.tripScheduleItem.aggregate({
      where: { dayId: input.dayId },
      _max: { sortOrder: true },
    });
    const nextSort = (maxSort._max.sortOrder ?? -1) + 1;

    const item = await prisma.tripScheduleItem.create({
      data: {
        dayId: input.dayId,
        startTime: input.startTime,
        endTime: input.endTime ?? null,
        title: input.title,
        description: input.description ?? null,
        locationName: input.locationName ?? null,
        latitude: input.latitude ?? null,
        longitude: input.longitude ?? null,
        sortOrder: input.sortOrder ?? nextSort,
        statusOverride: input.statusOverride ?? null,
        note: input.note ?? null,
      },
    });
    return item;
  },

  async deleteTripScheduleItem(tripId: string, itemId: string) {
    const item = await prisma.tripScheduleItem.findFirst({
      where: { id: itemId, day: { tripId } },
    });
    if (!item) return null;
    await prisma.tripScheduleItem.delete({ where: { id: itemId } });
    return { ok: true };
  },

  async addTripScheduleDay(tripId: string, input: ScheduleDayInput) {
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
      select: { id: true },
    });
    if (!trip) return null;
    if (!Number.isInteger(input.dayNumber) || input.dayNumber < 1) {
      throw new Error("dayNumber must be a positive integer");
    }

    const existing = await prisma.tripScheduleDay.findUnique({
      where: { tripId_dayNumber: { tripId, dayNumber: input.dayNumber } },
    });
    if (existing) throw new Error(`Day ${input.dayNumber} already exists`);

    const day = await prisma.tripScheduleDay.create({
      data: {
        tripId,
        dayNumber: input.dayNumber,
        title: input.title ?? null,
      },
    });
    return day;
  },

  async deleteTripScheduleDay(tripId: string, dayId: string) {
    const day = await prisma.tripScheduleDay.findFirst({
      where: { id: dayId, tripId },
    });
    if (!day) return null;
    await prisma.tripScheduleItem.deleteMany({ where: { dayId } });
    await prisma.tripScheduleDay.delete({ where: { id: dayId } });
    return { ok: true };
  },
};
