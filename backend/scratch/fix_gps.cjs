const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const items = await prisma.tripScheduleItem.findMany({
    where: {
      latitude: null,
      longitude: null
    }
  });
  
  console.log(`Found ${items.length} items without GPS.`);
  
  for (const item of items) {
    // Add some random jitter around Phu Quoc
    const lat = 10.21 + (Math.random() - 0.5) * 0.05;
    const lng = 103.96 + (Math.random() - 0.5) * 0.05;
    
    await prisma.tripScheduleItem.update({
      where: { id: item.id },
      data: {
        latitude: lat,
        longitude: lng
      }
    });
  }
  
  console.log('Done fixing GPS coordinates.');
}

main().catch(console.error).finally(() => prisma.$disconnect());
