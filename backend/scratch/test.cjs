const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const trips = await prisma.trip.findMany({
    include: {
      scheduleDays: {
        include: { items: true }
      }
    }
  });
  
  let valid = 0;
  for (const trip of trips) {
    if (trip.scheduleDays.length > 0 && trip.scheduleDays[0].items.length > 0) {
      valid++;
    }
  }
  
  console.log(`Total trips: ${trips.length}`);
  console.log(`Trips with schedules: ${valid}`);
}
main().catch(console.error).finally(() => prisma.$disconnect());
