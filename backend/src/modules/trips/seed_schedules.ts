import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Seeding Schedule Templates...");

  // 1. Delete existing schedules if any
  await prisma.tripScheduleUpdate.deleteMany();
  await prisma.tripScheduleItem.deleteMany();
  await prisma.tripScheduleDay.deleteMany();
  await prisma.scheduleTemplateItem.deleteMany();
  await prisma.scheduleTemplateDay.deleteMany();
  await prisma.scheduleTemplate.deleteMany();

  // 2. Create Schedule Template for Phú Quốc (sourceType: 'destination', destinationId: 'phuquoc')
  const phuquocTemplate = await prisma.scheduleTemplate.create({
    data: {
      name: "Khám Phá Đảo Ngọc Phú Quốc",
      sourceType: "destination",
      destinationId: "phuquoc",
      days: {
        create: [
          {
            dayNumber: 1,
            title: "Đến Đảo Ngọc - Hoàng Hôn Bãi Trường",
            items: {
              create: [
                { startTime: "08:00", endTime: "10:00", title: "Đón khách tại sân bay", description: "Xe đón đoàn tại sân bay Phú Quốc đưa về khách sạn.", locationName: "Sân bay Phú Quốc", sortOrder: 0 },
                { startTime: "10:30", endTime: "12:00", title: "Tự do tham quan & Nhận phòng", description: "Khách tự do nghỉ ngơi và nhận phòng khách sạn.", sortOrder: 1 },
                { startTime: "12:00", endTime: "13:30", title: "Ăn trưa đặc sản", description: "Thưởng thức Gỏi cá trích tại nhà hàng.", sortOrder: 2 },
                { startTime: "15:00", endTime: "18:00", title: "Ngắm hoàng hôn", description: "Di chuyển đến Sunset Sanato ngắm hoàng hôn cực đẹp.", locationName: "Bãi Trường", sortOrder: 3 },
              ]
            }
          },
          {
            dayNumber: 2,
            title: "Khám Phá Biển Đảo",
            items: {
              create: [
                { startTime: "07:00", endTime: "08:30", title: "Ăn sáng buffet", description: "Ăn sáng tại khách sạn.", sortOrder: 0 },
                { startTime: "09:00", endTime: "12:00", title: "Lặn ngắm san hô", description: "Tham gia tour 3 đảo, lặn ngắm rạn san hô tuyệt đẹp.", locationName: "Hòn Thơm", sortOrder: 1 },
                { startTime: "12:30", endTime: "14:00", title: "Ăn trưa trên đảo", description: "Dùng bữa trưa hải sản trên đảo.", sortOrder: 2 },
                { startTime: "15:00", endTime: "17:30", title: "Vui chơi VinWonders", description: "Khám phá công viên giải trí hàng đầu.", locationName: "VinWonders Phú Quốc", sortOrder: 3 },
              ]
            }
          }
        ]
      }
    }
  });
  console.log("Created template for Phú Quốc");

  // 3. Create Schedule Template for Đà Lạt (id: "dalat")
  const dalatTemplate = await prisma.scheduleTemplate.create({
    data: {
      name: "Đà Lạt Mộng Mơ",
      sourceType: "destination",
      destinationId: "dalat",
      days: {
        create: [
          {
            dayNumber: 1,
            title: "Khám phá Thành phố Hoa",
            items: {
              create: [
                { startTime: "08:30", endTime: "09:00", title: "Đón khách", description: "Xe đón khách tại bến xe/sân bay.", locationName: "Đà Lạt", sortOrder: 0 },
                { startTime: "09:30", endTime: "11:30", title: "Tham quan Thung Lũng Tình Yêu", description: "Chụp ảnh tại các tiểu cảnh lãng mạn.", locationName: "Thung Lũng Tình Yêu", sortOrder: 1 },
                { startTime: "12:00", endTime: "13:00", title: "Ăn trưa", description: "Thưởng thức Lẩu Gà Lá É.", sortOrder: 2 },
                { startTime: "14:00", endTime: "16:30", title: "Khám phá Thác Datanla", description: "Chơi máng trượt và ngắm thác.", locationName: "Thác Datanla", sortOrder: 3 },
                { startTime: "19:00", endTime: "21:00", title: "Chợ đêm Đà Lạt", description: "Thưởng thức bánh tráng nướng, sữa đậu nành.", locationName: "Chợ Âm Phủ", sortOrder: 4 },
              ]
            }
          }
        ]
      }
    }
  });
  console.log("Created template for Đà Lạt");

  // 4. Update existing trips that match these destinations to have a schedule
  const trips = await prisma.trip.findMany();
  for (const trip of trips) {
    let template = null;
    if (trip.destination.includes("Phú Quốc")) {
      template = await prisma.scheduleTemplate.findUnique({ where: { id: phuquocTemplate.id }, include: { days: { include: { items: true } } } });
    } else if (trip.destination.includes("Đà Lạt")) {
      template = await prisma.scheduleTemplate.findUnique({ where: { id: dalatTemplate.id }, include: { days: { include: { items: true } } } });
    }

    if (template) {
      // Create trip schedule
      for (const day of template.days) {
        const createdDay = await prisma.tripScheduleDay.create({
          data: {
            tripId: trip.id,
            dayNumber: day.dayNumber,
            title: day.title,
            // Simple date generation for demo
            date: new Date(Date.now() + (day.dayNumber - 1) * 86400000),
          }
        });
        for (const item of day.items) {
          await prisma.tripScheduleItem.create({
            data: {
              dayId: createdDay.id,
              startTime: item.startTime,
              endTime: item.endTime,
              title: item.title,
              description: item.description,
              locationName: item.locationName,
              sortOrder: item.sortOrder,
            }
          });
        }
      }
      console.log(`Assigned schedule to trip: ${trip.id}`);
    }
  }

  console.log("✅ Seeding Schedules Completed.");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
