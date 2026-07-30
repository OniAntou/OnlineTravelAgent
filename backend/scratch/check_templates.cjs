const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const templates = await prisma.scheduleTemplate.findMany({
    include: {
      destination: true,
      tourPackage: true,
      days: {
        include: { items: true }
      }
    }
  });
  
  console.log(`Found ${templates.length} templates.`);
  for (const t of templates) {
    console.log(`- Template ${t.id} for ${t.sourceType}: ${t.name}`);
    let missingGps = 0;
    for (const d of t.days) {
      for (const i of d.items) {
        if (!i.latitude || !i.longitude) missingGps++;
      }
    }
    console.log(`  Items missing GPS: ${missingGps}`);
  }
}
main().catch(console.error).finally(() => prisma.$disconnect());
