import prisma from "../config/prisma.js";

export type ScheduleSourceType = "tour" | "destination";

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

const allowedOverrides = new Set(["completed", "ongoing", "upcoming", "cancelled", "delayed"]);

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
  if (input.sourceType === "tour" && (!hasTour || hasDestination)) {
    throw new Error("tour template requires tourPackageId only");
  }
  if (input.sourceType === "destination" && (!hasDestination || hasTour)) {
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
  const match = value.match(/(\d{1,2})\/(\d{1,2})\/(\d{4})/);
  if (!match) return null;

  const day = Number.parseInt(match[1] ?? "", 10);
  const month = Number.parseInt(match[2] ?? "", 10);
  const year = Number.parseInt(match[3] ?? "", 10);
  if (!day || !month || !year) return null;

  const date = new Date(Date.UTC(year, month - 1, day));
  if (
    date.getUTCFullYear() !== year ||
    date.getUTCMonth() !== month - 1 ||
    date.getUTCDate() !== day
  ) {
    return null;
  }
  return date;
}

function addDays(date: Date, days: number): Date {
  const result = new Date(date);
  result.setUTCDate(result.getUTCDate() + days);
  return result;
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

async function createTemplateDays(tx: any, templateId: string, days: ScheduleDayInput[] = []) {
  for (const day of days) {
    const createdDay = await tx.scheduleTemplateDay.create({
      data: {
        templateId,
        dayNumber: day.dayNumber,
        title: day.title ?? null,
      },
    });

    for (const [index, item] of (day.items ?? []).entries()) {
      await tx.scheduleTemplateItem.create({
        data: {
          dayId: createdDay.id,
          startTime: item.startTime,
          endTime: item.endTime ?? null,
          title: item.title,
          description: item.description ?? null,
          locationName: item.locationName ?? null,
          latitude: item.latitude ?? null,
          longitude: item.longitude ?? null,
          sortOrder: normalizeSortOrder(item, index),
        },
      });
    }
  }
}

async function createTripDays(tx: any, tripId: string, days: ScheduleDayInput[] = []) {
  for (const day of days) {
    const createdDay = await tx.tripScheduleDay.create({
      data: {
        tripId,
        dayNumber: day.dayNumber,
        date: toNullableDate(day.date),
        title: day.title ?? null,
      },
    });

    for (const [index, item] of (day.items ?? []).entries()) {
      await tx.tripScheduleItem.create({
        data: {
          dayId: createdDay.id,
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
        },
      });
    }
  }
}

export const scheduleService = {
  async getScheduleTemplates() {
    return prisma.scheduleTemplate.findMany({
      include: {
        days: {
          orderBy: { dayNumber: "asc" },
          include: { items: { orderBy: [{ sortOrder: "asc" }, { startTime: "asc" }] } },
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
            include: { items: { orderBy: [{ sortOrder: "asc" }, { startTime: "asc" }] } },
          },
        },
      });
    });
  },

  async updateScheduleTemplate(id: string, input: ScheduleTemplateInput) {
    assertSource(input);
    assertItems(input.days);

    return prisma.$transaction(async (tx) => {
      await tx.scheduleTemplateItem.deleteMany({ where: { day: { templateId: id } } });
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
            include: { items: { orderBy: [{ sortOrder: "asc" }, { startTime: "asc" }] } },
          },
        },
      });
    });
  },

  async deleteScheduleTemplate(id: string) {
    await prisma.scheduleTemplate.delete({ where: { id } });
    return { ok: true };
  },

  async copyTemplateToTrip(params: {
    tripId: string;
    sourceType: ScheduleSourceType;
    sourceId: string;
    tripDate?: string | null;
  }) {
    const existing = await prisma.tripScheduleDay.count({ where: { tripId: params.tripId } });
    if (existing > 0) return;

    const template = await prisma.scheduleTemplate.findFirst({
      where:
        params.sourceType === "tour"
          ? { sourceType: "tour", tourPackageId: params.sourceId }
          : { sourceType: "destination", destinationId: params.sourceId },
      include: {
        days: {
          orderBy: { dayNumber: "asc" },
          include: { items: { orderBy: [{ sortOrder: "asc" }, { startTime: "asc" }] } },
        },
      },
    });
    if (!template) return;

    const startDate = parseTripStartDate(params.tripDate);
    await prisma.$transaction(async (tx) => {
      for (const day of template.days) {
        const createdDay = await tx.tripScheduleDay.create({
          data: {
            tripId: params.tripId,
            dayNumber: day.dayNumber,
            date: startDate ? addDays(startDate, day.dayNumber - 1) : null,
            title: day.title,
          },
        });

        for (const item of day.items) {
          await tx.tripScheduleItem.create({
            data: {
              dayId: createdDay.id,
              startTime: item.startTime,
              endTime: item.endTime,
              title: item.title,
              description: item.description,
              locationName: item.locationName,
              latitude: item.latitude,
              longitude: item.longitude,
              sortOrder: item.sortOrder,
            },
          });
        }
      }
    });
  },

  async getTripSchedule(tripId: string, requesterUserId?: string) {
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
      select: { id: true, userId: true },
    });
    if (!trip) return null;
    if (requesterUserId !== undefined && trip.userId !== requesterUserId) return null;

    const [days, updates] = await Promise.all([
      prisma.tripScheduleDay.findMany({
        where: { tripId },
        orderBy: { dayNumber: "asc" },
        include: { items: { orderBy: [{ sortOrder: "asc" }, { startTime: "asc" }] } },
      }),
      prisma.tripScheduleUpdate.findMany({
        where: { tripId },
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return { tripId, days, updates };
  },

  async updateTripSchedule(tripId: string, days: ScheduleDayInput[] = []) {
    const trip = await prisma.trip.findUnique({ where: { id: tripId }, select: { id: true } });
    if (!trip) return null;
    assertItems(days);

    return prisma.$transaction(async (tx) => {
      await tx.tripScheduleItem.deleteMany({ where: { day: { tripId } } });
      await tx.tripScheduleDay.deleteMany({ where: { tripId } });
      await createTripDays(tx, tripId, days);
      const savedDays = await tx.tripScheduleDay.findMany({
        where: { tripId },
        orderBy: { dayNumber: "asc" },
        include: { items: { orderBy: [{ sortOrder: "asc" }, { startTime: "asc" }] } },
      });
      const updates = await tx.tripScheduleUpdate.findMany({
        where: { tripId },
        orderBy: { createdAt: "desc" },
      });
      return { tripId, days: savedDays, updates };
    });
  },

  async createTripScheduleUpdate(tripId: string, message: string) {
    const trip = await prisma.trip.findUnique({ where: { id: tripId }, select: { id: true } });
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

  async addTripScheduleItem(tripId: string, input: ScheduleItemInput & { dayId: string }) {
    const day = await prisma.tripScheduleDay.findFirst({ where: { id: input.dayId, tripId } });
    if (!day) return null;
    assertClockTime(input.startTime, "startTime");
    if (input.endTime) assertClockTime(input.endTime, "endTime");
    if (!input.title?.trim()) throw new Error("title is required");

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
    const trip = await prisma.trip.findUnique({ where: { id: tripId }, select: { id: true } });
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
    const day = await prisma.tripScheduleDay.findFirst({ where: { id: dayId, tripId } });
    if (!day) return null;
    await prisma.tripScheduleItem.deleteMany({ where: { dayId } });
    await prisma.tripScheduleDay.delete({ where: { id: dayId } });
    return { ok: true };
  },
};
