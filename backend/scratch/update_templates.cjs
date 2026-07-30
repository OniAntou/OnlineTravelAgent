const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const DESTINATIONS = [
  { keywords: ['Đà Lạt'], lat: 11.94, lng: 108.43 },
  { keywords: ['Phú Quốc'], lat: 10.22, lng: 103.96 },
  { keywords: ['Phú Quý'], lat: 10.51, lng: 108.93 },
  { keywords: ['Hạ Long'], lat: 20.95, lng: 107.04 },
  { keywords: ['Tràng An', 'Ninh Bình'], lat: 20.25, lng: 105.97 },
  { keywords: ['Sapa'], lat: 22.33, lng: 103.84 },
  { keywords: ['Phong Nha'], lat: 17.58, lng: 106.28 },
  { keywords: ['Miền Trung', 'Đà Nẵng', 'Huế'], lat: 16.05, lng: 108.20 },
];

async function main() {
  const templates = await prisma.scheduleTemplate.findMany({
    include: {
      days: {
        include: { items: true }
      }
    }
  });
  
  for (const t of templates) {
    let baseCoord = { lat: 16.0, lng: 108.0 }; // default center Vietnam
    for (const d of DESTINATIONS) {
      if (d.keywords.some(k => t.name.includes(k))) {
        baseCoord = { lat: d.lat, lng: d.lng };
        break;
      }
    }
    
    for (const day of t.days) {
      for (const item of day.items) {
        if (!item.latitude || !item.longitude) {
          const jitterLat = (Math.random() - 0.5) * 0.04;
          const jitterLng = (Math.random() - 0.5) * 0.04;
          await prisma.scheduleTemplateItem.update({
            where: { id: item.id },
            data: {
              latitude: baseCoord.lat + jitterLat,
              longitude: baseCoord.lng + jitterLng
            }
          });
        }
      }
    }
    console.log(`Updated coordinates for ${t.name}`);
  }
}
main().catch(console.error).finally(() => prisma.$disconnect());
