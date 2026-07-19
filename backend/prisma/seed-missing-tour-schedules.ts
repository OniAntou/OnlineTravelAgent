import { PrismaClient, ScheduleSourceType } from "@prisma/client";
import { missingTourScheduleTemplates } from "./missing-tour-schedule-data.js";

const prisma = new PrismaClient();

async function main() {
  for (const definition of missingTourScheduleTemplates) {
    const tour = await prisma.tourPackage.findUnique({
      where: { id: definition.tourPackageId },
      select: { id: true },
    });
    if (!tour) throw new Error(`Tour not found: ${definition.tourPackageId}`);

    const existing = await prisma.scheduleTemplate.findUnique({
      where: {
        sourceType_tourPackageId: {
          sourceType: ScheduleSourceType.tour,
          tourPackageId: definition.tourPackageId,
        },
      },
      select: { id: true },
    });
    if (existing) {
      console.log(`Skipped existing template: ${definition.tourPackageId}`);
      continue;
    }

    await prisma.scheduleTemplate.create({
      data: {
        name: definition.name,
        sourceType: ScheduleSourceType.tour,
        tourPackageId: definition.tourPackageId,
        days: {
          create: definition.days.map((day) => ({
            dayNumber: day.dayNumber,
            title: day.title,
            items: { create: day.items },
          })),
        },
      },
    });
    console.log(`Created template: ${definition.tourPackageId}`);
  }
}

main()
  .catch((error: unknown) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
