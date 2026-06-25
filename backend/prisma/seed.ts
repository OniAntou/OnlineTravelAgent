import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Seeding database with rich data...");

  // Clean up existing data
  await prisma.tripScheduleUpdate.deleteMany();
  await prisma.tripScheduleItem.deleteMany();
  await prisma.tripScheduleDay.deleteMany();
  await prisma.scheduleTemplateItem.deleteMany();
  await prisma.scheduleTemplateDay.deleteMany();
  await prisma.scheduleTemplate.deleteMany();
  
  await prisma.room.deleteMany();
  await prisma.hotel.deleteMany();
  await prisma.tourPackage.deleteMany();
  await prisma.documentItem.deleteMany();
  await prisma.trip.deleteMany();
  await prisma.flight.deleteMany();
  await prisma.destination.deleteMany();
  await prisma.category.deleteMany();

  // --- Categories ---
  const categoryNames = ["Tất cả", "Địa điểm", "Khách sạn", "Máy bay", "Ẩm thực"];
  for (const name of categoryNames) {
    await prisma.category.create({ data: { name } });
  }
  console.log(`  Category Seeding: Created ${categoryNames.length} categories.`);

  // --- Destinations ---
  const destinations = [
    {
      id: "dalat",
      name: "Đà Lạt",
      location: "Lâm Đồng, VN",
      duration: "4N/5D",
      imagePath: "assets/images/dalat_image.jpg",
      description:
        "Đà Lạt là thành phố ngàn hoa với khí hậu ôn đới mát mẻ quanh năm. Nơi đây sở hữu cảnh sắc lãng mạn như Hồ Xuân Hương, Thung Lũng Tình Yêu, Thác Datanla và nền ẩm thực đêm cực kỳ hấp dẫn.",
      price: 4975000,
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: true,
      latitude: 11.9404,
      longitude: 108.4583,
    },
    {
      id: "phuquoc",
      name: "Đảo Phú Quốc",
      location: "Kiên Giang, VN",
      duration: "3N/2Đ",
      imagePath: "assets/images/phuquoc_image.jpg",
      description:
        "Đảo ngọc Phú Quốc nổi tiếng với các bãi biển nguyên sơ như Bãi Sao, Bãi Khem. Trải nghiệm hoàng hôn rực rỡ, lặn biển ngắm rạn san hô, đi cáp treo vượt biển Hòn Thơm và thưởng thức gỏi cá trích đặc sản.",
      price: 6250000,
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: true,
      latitude: 10.227,
      longitude: 103.967,
    },
    {
      id: "hoian",
      name: "Hội An",
      location: "Quảng Nam, VN",
      duration: "2N/1Đ",
      imagePath: "assets/images/hoian_image.webp",
      description:
        "Phố cổ Hội An - Di sản Văn hóa Thế giới lung linh dưới ánh đèn lồng vào ban đêm. Du khách có thể thả hoa đăng trên sông Hoài, check-in Chùa Cầu cổ kính và thưởng thức Cao Lầu ngon nức tiếng.",
      price: 3750000,
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: true,
      latitude: 15.8801,
      longitude: 108.338,
    },
    {
      id: "sapa",
      name: "Sapa",
      location: "Lào Cai, VN",
      duration: "3N/2Đ",
      imagePath: "assets/images/sapa_image.png",
      description:
        "Sapa ẩn hiện trong sương mờ với đỉnh Fansipan - nóc nhà Đông Dương hùng vĩ. Chiêm ngưỡng ruộng bậc thang tầng tầng lớp lớp tại Bản Cát Cát, thung lũng Mường Hoa và trải nghiệm văn hóa bản địa độc đáo.",
      price: 4500000,
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: true,
      latitude: 22.3364,
      longitude: 103.8438,
    },
    {
      id: "halong",
      name: "Vịnh Hạ Long",
      location: "Quảng Ninh, VN",
      duration: "2N/1Đ",
      imagePath: "assets/images/halong_image.png",
      description:
        "Vịnh Hạ Long với hàng ngàn đảo đá vôi dựng đứng kỳ vĩ nổi lên từ làn nước xanh ngọc. Trải nghiệm ngủ đêm trên du thuyền 5 sao sang trọng, chèo kayak luồn qua hang luồn và ngắm toàn cảnh vịnh từ đỉnh Ti Tốp.",
      price: 5500000,
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: true,
      latitude: 20.9754,
      longitude: 107.0474,
    },
    {
      id: "phongnha",
      name: "Phong Nha",
      location: "Quảng Bình, VN",
      duration: "3N/2Đ",
      imagePath: "assets/images/hoian_image.webp",
      description:
        "Vương quốc hang động Phong Nha - Kẻ Bàng với những kỳ quan thạch nhũ triệu năm tuổi. Khám phá Động Phong Nha nước chảy trong xanh, Động Thiên Đường tráng lệ và thử thách đu dây zipline tại Sông Chày Hang Tối.",
      price: 3250000,
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: false,
      latitude: 17.5907,
      longitude: 106.2848,
    },
    {
      id: "ninhbinh",
      name: "Tràng An",
      location: "Ninh Bình, VN",
      duration: "2N/1Đ",
      imagePath: "assets/images/hoian_image.webp",
      description:
        "Quần thể danh thắng Tràng An ví như 'Hạ Long trên cạn' với hệ thống hang động xuyên thủy kỳ ảo. Ngồi thuyền nan trôi theo dòng sông Sào Khê ngắm vách núi đá vôi dựng đứng và ghé thăm Hang Múa ngắm trọn thung lũng lúa vàng.",
      price: 2750000,
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: true,
      latitude: 20.2528,
      longitude: 105.9744,
    },
    {
      id: "phuquy",
      name: "Đảo Phú Quý",
      location: "Bình Thuận, VN",
      duration: "3N/2Đ",
      imagePath: "assets/images/phuquoc_image.jpg",
      description:
        "Đảo Phú Quý hoang sơ giữa đại dương xanh ngắt với làn nước trong vắt có thể nhìn thấy rạn san hô dưới đáy. Khám phá Dốc Phượt đầy nắng, check-in cột cờ chủ quyền, ngắm hoàng hôn đỉnh Cao Cát và thưởng thức cua huỳnh đế giá rẻ.",
      price: 3000000,
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: false,
      latitude: 10.5186,
      longitude: 108.9404,
    },
    {
      id: "danang",
      name: "Đà Nẵng",
      location: "Đà Nẵng, VN",
      duration: "3N/2Đ",
      imagePath: "assets/images/danang_image.png",
      description:
        "Thành phố đáng sống bậc nhất với bãi biển Mỹ Khê cát trắng mịn, cầu Rồng phun lửa ấn tượng ban đêm. Khám phá Bà Nà Hills với Cầu Vàng nổi tiếng toàn cầu, Ngũ Hành Sơn huyền thoại và bán đảo Sơn Trà hoang sơ.",
      price: 4000000,
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: true,
      latitude: 16.0544,
      longitude: 108.2022,
    },
    {
      id: "hanoi",
      name: "Hà Nội",
      location: "Hà Nội, VN",
      duration: "2N/1Đ",
      imagePath: "assets/images/hanoi_image.png",
      description:
        "Thủ đô ngàn năm văn hiến mang nét trầm mặc cổ kính pha lẫn hiện đại. Dạo quanh 36 phố phường nhộn nhịp, viếng Lăng Bác, check-in Hồ Gươm thanh bình và khám phá thiên đường ẩm thực đường phố: Phở, Bún chả, Cà phê trứng.",
      price: 3500000,
      category: "Ẩm thực",
      isFavorite: false,
      isRecommended: false,
      latitude: 21.0285,
      longitude: 105.8542,
    },
    {
      id: "nhatrang",
      name: "Nha Trang",
      location: "Khánh Hòa, VN",
      duration: "3N/2Đ",
      imagePath: "assets/images/phuquoc_image.jpg",
      description:
        "Vịnh biển Nha Trang tuyệt đẹp với các hòn đảo Hòn Tre, Hòn Mun trong xanh. Trải nghiệm các trò chơi cảm giác mạnh trên biển, tắm bùn khoáng nóng thư giãn và ăn hải sản nướng thơm ngon trên bãi cát.",
      price: 4250000,
      category: "Địa điểm",
      isFavorite: false,
      isRecommended: false,
      latitude: 12.2388,
      longitude: 109.1967,
    },
  ];

  for (const dest of destinations) {
    await prisma.destination.create({ data: dest });
  }
  console.log(`  Destination Seeding: Created ${destinations.length} destinations.`);

  // --- Trips ---
  const trips = [
    {
      id: "trip-1",
      destination: "Đảo Phú Quốc",
      location: "Kiên Giang, VN",
      date: "20/05/2026 - 23/05/2026",
      guests: "2 Người lớn",
      status: "Sắp tới",
      imagePath: "assets/images/phuquoc_image.jpg",
      isUpcoming: true,
    },
    {
      id: "trip-2",
      destination: "Hội An",
      location: "Quảng Nam, VN",
      date: "15/04/2026 - 17/04/2026",
      guests: "1 Người lớn",
      status: "Đã đi",
      imagePath: "assets/images/hoian_image.webp",
      isUpcoming: false,
    },
    {
      id: "trip-3",
      destination: "Đà Lạt",
      location: "Lâm Đồng, VN",
      date: "10/03/2026 - 14/03/2026",
      guests: "2 Người lớn, 1 Trẻ em",
      status: "Đã đi",
      imagePath: "assets/images/dalat_image.jpg",
      isUpcoming: false,
    },
    {
      id: "trip-4",
      destination: "Sapa",
      location: "Lào Cai, VN",
      date: "15/12/2026 - 18/12/2026",
      guests: "2 Người lớn",
      status: "Sắp tới",
      imagePath: "assets/images/sapa_image.png",
      isUpcoming: true,
    },
    {
      id: "trip-5",
      destination: "Vịnh Hạ Long",
      location: "Quảng Ninh, VN",
      date: "05/01/2027 - 07/01/2027",
      guests: "3 Người lớn",
      status: "Sắp tới",
      imagePath: "assets/images/halong_image.png",
      isUpcoming: true,
    },
    {
      id: "trip-6",
      destination: "Nha Trang",
      location: "Khánh Hòa, VN",
      date: "12/01/2026 - 15/01/2026",
      guests: "2 Người lớn",
      status: "Đã đi",
      imagePath: "assets/images/phuquoc_image.jpg",
      isUpcoming: false,
    },
    {
      id: "trip-7",
      destination: "Khám Phá Đà Lạt Mộng Mơ",
      location: "Lâm Đồng, VN",
      date: "Hôm nay - 3 Ngày nữa",
      guests: "2 Người lớn",
      status: "Đang diễn ra",
      imagePath: "assets/images/dalat_image.jpg",
      isUpcoming: true,
    },
  ];

  for (const trip of trips) {
    await prisma.trip.create({ data: trip });
  }
  console.log(`  Trip Seeding: Created ${trips.length} trips.`);

  // --- Flights ---
  const flights = [
    {
      id: "fl-1",
      airline: "Vietnam Airlines",
      airlineLogo: "assets/images/vna_logo.png",
      departure: "SGN",
      arrival: "HAN",
      departureTime: "08:30",
      arrivalTime: "10:45",
      price: 3000000,
      duration: "2h 15m",
    },
    {
      id: "fl-2",
      airline: "Vietjet Air",
      airlineLogo: "assets/images/vj_logo.png",
      departure: "SGN",
      arrival: "HAN",
      departureTime: "09:00",
      arrivalTime: "11:10",
      price: 2125000,
      duration: "2h 10m",
    },
    {
      id: "fl-3",
      airline: "Bamboo Airways",
      airlineLogo: "assets/images/bb_logo.png",
      departure: "SGN",
      arrival: "HAN",
      departureTime: "14:00",
      arrivalTime: "16:15",
      price: 2375000,
      duration: "2h 15m",
    },
    {
      id: "fl-4",
      airline: "Vietnam Airlines",
      airlineLogo: "assets/images/vna_logo.png",
      departure: "HAN",
      arrival: "SGN",
      departureTime: "12:15",
      arrivalTime: "14:30",
      price: 3250000,
      duration: "2h 15m",
    },
    {
      id: "fl-5",
      airline: "Vietjet Air",
      airlineLogo: "assets/images/vj_logo.png",
      departure: "HAN",
      arrival: "SGN",
      departureTime: "18:00",
      arrivalTime: "20:10",
      price: 2000000,
      duration: "2h 10m",
    },
    {
      id: "fl-6",
      airline: "Vietnam Airlines",
      airlineLogo: "assets/images/vna_logo.png",
      departure: "SGN",
      arrival: "DLI",
      departureTime: "07:00",
      arrivalTime: "07:55",
      price: 1625000,
      duration: "0h 55m",
    },
    {
      id: "fl-7",
      airline: "Vietjet Air",
      airlineLogo: "assets/images/vj_logo.png",
      departure: "SGN",
      arrival: "DLI",
      departureTime: "11:30",
      arrivalTime: "12:20",
      price: 1125000,
      duration: "0h 50m",
    },
    {
      id: "fl-8",
      airline: "Bamboo Airways",
      airlineLogo: "assets/images/bb_logo.png",
      departure: "SGN",
      arrival: "PQC",
      departureTime: "14:00",
      arrivalTime: "15:00",
      price: 2375000,
      duration: "1h 00m",
    },
    {
      id: "fl-9",
      airline: "Vietnam Airlines",
      airlineLogo: "assets/images/vna_logo.png",
      departure: "HAN",
      arrival: "DLI",
      departureTime: "06:15",
      arrivalTime: "08:10",
      price: 3750000,
      duration: "1h 55m",
    },
    {
      id: "fl-10",
      airline: "Vietnam Airlines",
      airlineLogo: "assets/images/vna_logo.png",
      departure: "SGN",
      arrival: "DAD",
      departureTime: "10:30",
      arrivalTime: "11:55",
      price: 2750000,
      duration: "1h 25m",
    },
    {
      id: "fl-11",
      airline: "Vietjet Air",
      airlineLogo: "assets/images/vj_logo.png",
      departure: "HAN",
      arrival: "DAD",
      departureTime: "16:00",
      arrivalTime: "17:20",
      price: 1875000,
      duration: "1h 20m",
    },
    {
      id: "fl-12",
      airline: "Bamboo Airways",
      airlineLogo: "assets/images/bb_logo.png",
      departure: "SGN",
      arrival: "DAD",
      departureTime: "17:30",
      arrivalTime: "18:55",
      price: 2200000,
      duration: "1h 25m",
    },
    {
      id: "fl-13",
      airline: "Vietnam Airlines",
      airlineLogo: "assets/images/vna_logo.png",
      departure: "SGN",
      arrival: "CXR",
      departureTime: "06:00",
      arrivalTime: "07:05",
      price: 1750000,
      duration: "1h 05m",
    },
    {
      id: "fl-14",
      airline: "Vietjet Air",
      airlineLogo: "assets/images/vj_logo.png",
      departure: "HAN",
      arrival: "CXR",
      departureTime: "10:00",
      arrivalTime: "11:50",
      price: 2250000,
      duration: "1h 50m",
    },
    {
      id: "fl-15",
      airline: "Bamboo Airways",
      airlineLogo: "assets/images/bb_logo.png",
      departure: "HAN",
      arrival: "PQC",
      departureTime: "07:15",
      arrivalTime: "09:20",
      price: 4000000,
      duration: "2h 05m",
    },
    {
      id: "fl-16",
      airline: "Vietnam Airlines",
      airlineLogo: "assets/images/vna_logo.png",
      departure: "SGN",
      arrival: "HPH",
      departureTime: "15:20",
      arrivalTime: "17:25",
      price: 2625000,
      duration: "2h 05m",
    },
    {
      id: "fl-17",
      airline: "Vietjet Air",
      airlineLogo: "assets/images/vj_logo.png",
      departure: "SGN",
      arrival: "HPH",
      departureTime: "06:15",
      arrivalTime: "08:20",
      price: 1950000,
      duration: "2h 05m",
    },
    {
      id: "fl-18",
      airline: "Vietnam Airlines",
      airlineLogo: "assets/images/vna_logo.png",
      departure: "SGN",
      arrival: "VDH",
      departureTime: "11:00",
      arrivalTime: "12:35",
      price: 2875000,
      duration: "1h 35m",
    },
  ];

  for (const flight of flights) {
    await prisma.flight.create({ data: flight });
  }
  console.log(`  Flight Seeding: Created ${flights.length} flights.`);

  // --- Documents ---
  const documents = [
    { id: "doc-1", title: "Hộ chiếu", description: "Hết hạn: 12/2030", icon: "description", color: "#176FF2" },
    { id: "doc-2", title: "Visa", description: "Vietnam - Multiple Entry", icon: "assignment", color: "#4CAF50" },
    {
      id: "doc-3",
      title: "Bảo hiểm du lịch",
      description: "Bảo việt - Toàn cầu",
      icon: "verified_user",
      color: "#FF9800",
    },
    {
      id: "doc-4",
      title: "Vé máy bay",
      description: "Phú Quốc - Sài Gòn",
      icon: "flight_takeoff",
      color: "#E91E63",
    },
  ];

  for (const doc of documents) {
    await prisma.documentItem.create({ data: doc });
  }
  console.log(`  Document Seeding: Created ${documents.length} documents.`);

  // --- Hotels & Rooms ---
  const hotels = [
    {
      id: "ht-vinpearl-nhatrang",
      name: "Vinpearl Resort Nha Trang",
      location: "Nha Trang, VN",
      latitude: 12.2118,
      longitude: 109.1592,
      imagePath: "assets/images/phuquoc_image.jpg",
      description: "Khu nghỉ dưỡng 5 sao đẳng cấp quốc tế tọa lạc trên đảo Hòn Tre, với bãi biển riêng và công viên giải trí VinWonders.",
      priceFrom: 3750000,
      address: "Đảo Hòn Tre, Phường Vĩnh Nguyên, TP Nha Trang",
      amenities: ["Hồ bơi ngoài trời", "Spa chăm sóc sức khỏe", "Bãi biển riêng", "Nhà hàng buffet", "Phòng Gym hiện đại"],
    },
    {
      id: "ht-muongthanh-dalat",
      name: "Mường Thanh Holiday Đà Lạt",
      location: "Lâm Đồng, VN",
      latitude: 11.9421,
      longitude: 108.4552,
      imagePath: "assets/images/dalat_image.jpg",
      description: "Nằm ngay trung tâm thành phố Đà Lạt, tầm nhìn tuyệt đẹp ra Hồ Xuân Hương và thành phố mộng mơ với phong cách hoàng gia.",
      priceFrom: 1250000,
      address: "42 Phan Bội Châu, Phường 2, TP Đà Lạt",
      amenities: ["Hồ bơi nước ấm trong nhà", "Dịch vụ Spa & Massage", "Quầy Bar lãng mạn", "Nhà hàng ẩm thực Á-Âu", "Dịch vụ cho thuê xe tự lái"],
    },
    {
      id: "ht-intercon-phuquoc",
      name: "InterContinental Phu Quoc Long Beach",
      location: "Kiên Giang, VN",
      latitude: 10.1581,
      longitude: 103.9875,
      imagePath: "assets/images/phuquoc_image.jpg",
      description: "Trải nghiệm kỳ nghỉ xa hoa tại Bãi Trường với các tiện ích đẳng cấp thế giới, bể bơi vô cực khổng lồ và cảnh hoàng hôn tuyệt đỉnh.",
      priceFrom: 5000000,
      address: "Bãi Trường, Xã Dương Tơ, TP Phú Quốc",
      amenities: ["Hồ bơi vô cực sát biển", "Khu vui chơi trẻ em", "Harnn Heritage Spa", "Quầy bar Ink 360 cao nhất đảo", "Phòng thể hình đẳng cấp"],
    },
    {
      id: "ht-sapajade-hill",
      name: "Sapa Jade Hill Resort & Spa",
      location: "Lào Cai, VN",
      latitude: 22.3218,
      longitude: 103.8542,
      imagePath: "assets/images/sapa_image.png",
      description: "Khu nghỉ dưỡng sinh thái độc đáo ẩn mình giữa thung lũng Mường Hoa thơ mộng, với các biệt thự mái đá có lò sưởi ấm cúng.",
      priceFrom: 3000000,
      address: "Khu du lịch Mường Hoa, Lao Chải, Sa Pa",
      amenities: ["Hồ bơi nước nóng view thung lũng", "Hồng Hoa Spa bản địa", "Nhà hàng ẩm thực Tây Bắc", "Lò sưởi củi tự nhiên", "Tour đi bộ leo núi"],
    },
    {
      id: "ht-halong-plaza",
      name: "Ha Long Plaza Hotel",
      location: "Quảng Ninh, VN",
      latitude: 20.9575,
      longitude: 107.0733,
      imagePath: "assets/images/halong_image.png",
      description: "Tọa lạc tại trung tâm Bãi Cháy, khách sạn cung cấp tầm nhìn trực diện tuyệt đẹp ra Vịnh Hạ Long kỳ vĩ và cầu Bãi Cháy lung linh về đêm.",
      priceFrom: 2125000,
      address: "Số 8 Đường Hạ Long, Phường Bãi Cháy, TP Hạ Long",
      amenities: ["Bể bơi vô cực ngoài trời", "Trung tâm thể thao & Massage", "Lounge tầng thượng ngắm vịnh", "Nhà hàng hải sản tươi sống", "Dịch vụ phòng 24h"],
    },
    {
      id: "ht-phongnha-lake",
      name: "Phong Nha Lake House Resort",
      location: "Quảng Bình, VN",
      latitude: 17.5852,
      longitude: 106.2895,
      imagePath: "assets/images/sapa_image.png",
      description: "Khu nghỉ dưỡng sinh thái bình yên nằm bên hồ Đồng Bản thơ mộng, cửa ngõ tuyệt vời để thám hiểm hệ thống hang động Phong Nha.",
      priceFrom: 1375000,
      address: "Thôn Khương Hà, Xã Hưng Trạch, Huyện Bố Trạch",
      amenities: ["Hồ bơi ngoài trời sát hồ", "Cho thuê thuyền Kayak miễn phí", "Nhà hàng phong cách đồng quê", "Bar ngoài trời", "Tour thám hiểm hang động"],
    },
    {
      id: "ht-metropole-hanoi",
      name: "Sofitel Legend Metropole Hanoi",
      location: "Hà Nội, VN",
      latitude: 21.0253,
      longitude: 105.8569,
      imagePath: "assets/images/hanoi_image.png",
      description: "Khách sạn cổ kính mang phong cách kiến trúc Pháp thuộc từ năm 1901. Trải nghiệm lịch sử xa hoa, hầm trú ẩn lịch sử và nét ẩm thực thượng hạng.",
      priceFrom: 6500000,
      address: "15 Ngô Quyền, Quận Hoàn Kiếm, Hà Nội",
      amenities: ["Bể bơi nước nóng Le Club", "Le Spa du Metropole", "Hầm rượu cổ", "Nhà hàng Pháp chuẩn Michelin", "Quầy bar ngoài trời Angelina"],
    },
    {
      id: "ht-novotel-danang",
      name: "Novotel Danang Premier Han River",
      location: "Đà Nẵng, VN",
      latitude: 16.0792,
      longitude: 108.2238,
      imagePath: "assets/images/danang_image.png",
      description: "Khách sạn cao tầng hiện đại hàng đầu bên sông Hàn. Điểm ngắm pháo hoa quốc tế tuyệt đỉnh và sở hữu Sky36 - bar sân thượng cao nhất Đà Nẵng.",
      priceFrom: 2750000,
      address: "36 Bạch Đằng, Quận Hải Châu, Đà Nẵng",
      amenities: ["Bể bơi vô cực ngắm sông Hàn", "Sky36 Rooftop Bar", "InBalance Spa", "Nhà hàng ẩm thực quốc tế", "Phòng tập Gym tối tân"],
    },
  ];

  for (const hotel of hotels) {
    await prisma.hotel.create({ data: hotel });
  }
  console.log(`  Hotel Seeding: Created ${hotels.length} hotels.`);

  const rooms = [
    {
      id: "rm-vp-1",
      hotelId: "ht-vinpearl-nhatrang",
      name: "Deluxe Ocean View",
      description: "Phòng rộng 42m2 sang trọng với ban công lớn nhìn toàn cảnh vịnh Nha Trang xanh ngắt.",
      price: 3750000,
      capacity: 2,
      imagePath: "assets/images/phuquoc_image.jpg",
      amenities: ["Ban công riêng", "Bồn tắm nằm", "Minibar đầy đủ", "Wifi tốc độ cao"],
    },
    {
      id: "rm-vp-2",
      hotelId: "ht-vinpearl-nhatrang",
      name: "Villa 3-Bedroom Pool Ocean",
      description: "Biệt thự 3 phòng ngủ đẳng cấp có hồ bơi riêng biệt và lối đi thẳng ra bãi biển cát trắng.",
      price: 12000000,
      capacity: 6,
      imagePath: "assets/images/phuquoc_image.jpg",
      amenities: ["Hồ bơi riêng", "Bếp gia đình rộng rãi", "Sân tắm nắng", "Dịch vụ quản gia riêng"],
    },
    {
      id: "rm-mt-1",
      hotelId: "ht-muongthanh-dalat",
      name: "Superior Double Room",
      description: "Phòng đôi tiêu chuẩn ấm cúng mang phong cách cổ điển Pháp, trang bị máy sưởi.",
      price: 1250000,
      capacity: 2,
      imagePath: "assets/images/dalat_image.jpg",
      amenities: ["Cửa sổ lớn ngắm hồ", "Hệ thống sưởi ấm", "Ấm trà & Cà phê", "Truyền hình cáp"],
    },
    {
      id: "rm-mt-2",
      hotelId: "ht-muongthanh-dalat",
      name: "Executive Suite Lakeview",
      description: "Phòng Suite hoàng gia rộng rãi với phòng khách riêng biệt hướng thẳng ra Hồ Xuân Hương thơ mộng.",
      price: 2250000,
      capacity: 2,
      imagePath: "assets/images/dalat_image.jpg",
      amenities: ["View Hồ Xuân Hương trực diện", "Phòng khách riêng", "Trái cây chào mừng", "Bồn tắm thủy lực"],
    },
    {
      id: "rm-ic-1",
      hotelId: "ht-intercon-phuquoc",
      name: "Resort Classic Ocean View",
      description: "Không gian nghỉ dưỡng thanh lịch mang hơi thở đại dương với cửa kính kịch trần ngắm hoàng hôn Bãi Trường.",
      price: 5000000,
      capacity: 2,
      imagePath: "assets/images/phuquoc_image.jpg",
      amenities: ["Bồn tắm đứng độc lập", "Loa Bluetooth JBL", "Minibar cao cấp", "Máy pha cà phê Espresso"],
    },
    {
      id: "rm-sj-1",
      hotelId: "ht-sapajade-hill",
      name: "Deluxe Valley Bungalow",
      description: "Bungalow xây dựng bằng gỗ thông và đá núi tự nhiên, ban công nhìn ra thung lũng Mường Hoa mờ sương.",
      price: 3000000,
      capacity: 2,
      imagePath: "assets/images/sapa_image.png",
      amenities: ["Ban công ngắm mây", "Lò sưởi củi sưởi ấm", "Bồn tắm bằng gỗ pơ-mu", "Trà thảo mộc bản địa"],
    },
    {
      id: "rm-sj-2",
      hotelId: "ht-sapajade-hill",
      name: "Family Garden Villa 2-Bed",
      description: "Biệt thự 2 phòng ngủ ấm cúng có sân vườn đầy hoa mận hoa đào, lý tưởng cho kỳ nghỉ gia đình.",
      price: 5500000,
      capacity: 4,
      imagePath: "assets/images/sapa_image.png",
      amenities: ["Sân vườn riêng biệt", "Phòng khách ấm cúng", "Lò sưởi đá sành điệu", "Nhà bếp cơ bản"],
    },
    {
      id: "rm-hl-1",
      hotelId: "ht-halong-plaza",
      name: "Superior Bay View Room",
      description: "Phòng Superior hiện đại với cửa sổ lớn hướng biển nhìn ngắm các hòn đảo đá vôi nhấp nhô ngoài vịnh.",
      price: 2125000,
      capacity: 2,
      imagePath: "assets/images/halong_image.png",
      amenities: ["Tầm nhìn ngắm Vịnh biển", "Bồn tắm sang trọng", "Bàn làm việc lớn", "Nước uống chào mừng"],
    },
    {
      id: "rm-hl-2",
      hotelId: "ht-halong-plaza",
      name: "Executive Suite Sea View",
      description: "Phòng Suite cao cấp với diện tích vượt trội, trang thiết bị tối tân và đặc quyền sử dụng Executive Lounge.",
      price: 3750000,
      capacity: 2,
      imagePath: "assets/images/halong_image.png",
      amenities: ["Đặc quyền Lounge", "Giường siêu lớn King-size", "Bữa phụ & Rượu tối miễn phí", "Dịch vụ là ủi miễn phí"],
    },
    {
      id: "rm-pn-1",
      hotelId: "ht-phongnha-lake",
      name: "Lakefront Bungalow",
      description: "Bungalow lợp mái lá truyền thống nằm ngay sát rìa nước hồ, ban công lộng gió thích hợp câu cá, thư giãn.",
      price: 1375000,
      capacity: 2,
      imagePath: "assets/images/sapa_image.png",
      amenities: ["Ban công sát mép nước", "Võng thư giãn ngoài trời", "Điều hòa nhiệt độ", "Ấm đun nước"],
    },
    {
      id: "rm-pn-2",
      hotelId: "ht-phongnha-lake",
      name: "Family Lakeview Villa 2-Bed",
      description: "Biệt thự gia đình rộng rãi nhìn ra toàn cảnh hồ Đồng Bản yên bình giữa núi rừng Phong Nha hoang sơ.",
      price: 2500000,
      capacity: 4,
      imagePath: "assets/images/sapa_image.png",
      amenities: ["Ban công hồ vô cực", "Phòng sinh hoạt chung rộng", "Khu đỗ xe riêng", "Đồ ăn nhẹ chào mừng"],
    },
    {
      id: "rm-mp-1",
      hotelId: "ht-metropole-hanoi",
      name: "Premium Luxury Opera Wing",
      description: "Phòng ở phân khu Opera sang trọng với thiết kế tân cổ điển kết hợp tinh tế giữa văn hóa Pháp và Việt Nam.",
      price: 6500000,
      capacity: 2,
      imagePath: "assets/images/hanoi_image.png",
      amenities: ["Nội thất tân cổ điển Pháp", "Giường MyBed siêu êm", "Đồ tắm thương hiệu Hermes", "Dịch vụ quản gia Legend"],
    },
    {
      id: "rm-nd-1",
      hotelId: "ht-novotel-danang",
      name: "Superior Han River View",
      description: "Phòng Superior hiện đại tích hợp ban công ngắm trọn vẹn cảnh sông Hàn thơ mộng và các cây cầu lung linh.",
      price: 2750000,
      capacity: 2,
      imagePath: "assets/images/danang_image.png",
      amenities: ["Ban công ngắm Sông Hàn", "Bàn làm việc công nghệ", "Buồng tắm đứng vòi sen lớn", "Két sắt an toàn"],
    },
    {
      id: "rm-nd-2",
      hotelId: "ht-novotel-danang",
      name: "Executive Suite River Panorama",
      description: "Căn Suite góc sang trọng mở ra tầm nhìn toàn cảnh 180 độ sông Hàn và vịnh Đà Nẵng ở độ cao ấn tượng.",
      price: 4500000,
      capacity: 2,
      imagePath: "assets/images/danang_image.png",
      amenities: ["Góc nhìn toàn cảnh 180 độ", "Đặc quyền Premier Lounge", "Bồn tắm vô cực hướng sông", "Hệ thống âm thanh Bluetooth"],
    },
  ];

  for (const room of rooms) {
    await prisma.room.create({ data: room });
  }
  console.log(`  Room Seeding: Created ${rooms.length} hotel rooms.`);

  // --- Tour Packages ---
  const tours = [
    {
      id: "tour-dalat-3n2d",
      name: "Khám Phá Đà Lạt Mộng Mơ",
      description:
        "Hành trình trọn gói 3 ngày 2 đêm tìm kiếm sự yên bình của Đà Lạt. Khám phá đỉnh Langbiang hùng vĩ, chèo thuyền Kayak trên Hồ Tuyền Lâm và tận hưởng tiệc nướng BBQ trong rừng thông mát lạnh.",
      imagePath: "assets/images/dalat_image.jpg",
      duration: "3N/2Đ",
      price: 3750000,
      originalPrice: 4975000,
      destinations: ["Đà Lạt", "Lâm Đồng"],
      includes: ["Vé máy bay khứ hồi khứ hồi", "Khách sạn Mường Thanh 4 sao", "Xe du lịch đưa đón", "3 bữa ăn chính đặc sản", "Vé tham quan các điểm"],
      departure: "SGN",
      isPopular: true,
    },
    {
      id: "tour-phuquoc-4n3d",
      name: "Phú Quốc Biển Xanh Gọi Mời",
      description:
        "Nghỉ dưỡng trọn vẹn tại đảo ngọc Phú Quốc. Tour đi cano tham quan 4 đảo hoang sơ, lặn ngắm san hô bằng bình khí, vui chơi không giới hạn tại VinWonders & Safari và thưởng thức tiệc hải sản tối rực rỡ.",
      imagePath: "assets/images/phuquoc_image.jpg",
      duration: "4N/3Đ",
      price: 7475000,
      originalPrice: 9500000,
      destinations: ["Phú Quốc", "Kiên Giang"],
      includes: ["Vé máy bay khứ hồi", "Resort InterContinental 5 sao", "Cano thám hiểm 4 đảo", "Buffet sáng mỗi ngày", "Bảo hiểm du lịch trọn gói"],
      departure: "HAN",
      isPopular: true,
    },
    {
      id: "tour-mientrung-5n4d",
      name: "Hành Trình Di Sản Miền Trung",
      description:
        "Kết nối 3 điểm đến huyền thoại: Đà Nẵng - Hội An - Huế. Check-in Cầu Vàng Bà Nà Hills, dạo bước phố cổ đèn lồng trầm mặc và khám phá Đại Nội Huế tôn nghiêm, cổ kính.",
      imagePath: "assets/images/hoian_image.webp",
      duration: "5N/4Đ",
      price: 5500000,
      originalPrice: 7000000,
      destinations: ["Đà Nẵng", "Hội An", "Huế"],
      includes: ["Vé máy bay khứ hồi khứ hồi", "Khách sạn 3 sao trung tâm", "Hướng dẫn viên trọn tuyến", "Vé cáp treo Bà Nà Hills", "Du thuyền nghe ca Huế"],
      departure: "SGN",
      isPopular: false,
    },
    {
      id: "tour-sapa-3n2d",
      name: "Khám Phá Sapa Hùng Vĩ Sương Mờ",
      description:
        "Chinh phục đỉnh Fansipan 3.143m ngắm thung lũng mây trôi bồng bềnh. Tham quan bản cổ Bản Cát Cát của người H'Mông, trải nghiệm tắm lá thuốc Dao Đỏ và thưởng thức lẩu cá tầm nóng hổi giữa tiết trời lạnh giá.",
      imagePath: "assets/images/sapa_image.png",
      duration: "3N/2Đ",
      price: 3375000,
      originalPrice: 4375000,
      destinations: ["Sa Pa", "Lào Cai"],
      includes: ["Xe giường nằm khứ hồi khứ hồi", "Bungalow Sapa Jade Hill", "Vé cáp treo Fansipan khứ hồi", "Tắm lá thuốc người Dao", "Ăn sáng buffet"],
      departure: "HAN",
      isPopular: true,
    },
    {
      id: "tour-halong-2n1d",
      name: "Du Thuyền Vịnh Hạ Long 5 Sao",
      description:
        "Kỳ nghỉ thượng lưu trên du thuyền 5 sao lướt êm đềm giữa hàng ngàn hòn đảo kỳ vĩ. Trải nghiệm lớp học nấu ăn trên boong tàu, chèo kayak khám phá Hang Luồn hoang sơ, tập Thái Cực Quyền đón bình minh rực rỡ.",
      imagePath: "assets/images/halong_image.png",
      duration: "2N/1Đ",
      price: 4475000,
      originalPrice: 5750000,
      destinations: ["Hạ Long", "Quảng Ninh"],
      includes: ["Xe Limousine đưa đón", "Cabin Luxury ban công riêng", "4 bữa ăn hải sản thượng hạng", "Chèo thuyền Kayak & Vé đò", "Bảo hiểm hành trình"],
      departure: "HAN",
      isPopular: true,
    },
    {
      id: "tour-ninhbinh-2n1d",
      name: "Hành Trình Tràng An Cổ Kính",
      description:
        "Dòng sông Sào Khê đưa thuyền nan luồn qua các hang động kỳ bí của Tràng An. Viếng chùa Bái Đính khổng lồ sở hữu nhiều kỷ lục châu Á, leo 500 bậc đá đỉnh Hang Múa ngắm sông Ngô Đồng thơ mộng.",
      imagePath: "assets/images/hoian_image.webp",
      duration: "2N/1Đ",
      price: 2375000,
      originalPrice: 3125000,
      destinations: ["Tràng An", "Ninh Bình"],
      includes: ["Xe du lịch đời mới khứ hồi", "Khách sạn Ninh Bình 3 sao", "Vé đò Tràng An", "Vé tham quan Hang Múa", "Ăn trưa dê núi Ninh Bình"],
      departure: "HAN",
      isPopular: false,
    },
    {
      id: "tour-phuquy-3n2d",
      name: "Phượt Đảo Phú Quý Hoang Sơ",
      description:
        "Hòa mình vào vẻ đẹp nguyên sơ chưa từng có của hòn đảo ngọc hoang vu. Cano thám hiểm Hòn Tranh, lặn san hô đáy kính, dạo bước Dốc Phượt lộng gió và ngắm hoàng hôn buông lãng mạn trên đỉnh núi Cao Cát.",
      imagePath: "assets/images/phuquoc_image.jpg",
      duration: "3N/2Đ",
      price: 2875000,
      originalPrice: 3750000,
      destinations: ["Đảo Phú Quý", "Bình Thuận"],
      includes: ["Vé tàu cao tốc khứ hồi khứ hồi", "Khách sạn ven biển", "Xe máy di chuyển trên đảo", "Cano lặn ngắm san hô", "Tiệc tối hải sản nướng"],
      departure: "SGN",
      isPopular: true,
    },
    {
      id: "tour-phongnha-3n2d",
      name: "Thám Hiểm Hang Động Phong Nha",
      description:
        "Xuôi thuyền sông Son thám hiểm hang động ướt Phong Nha tuyệt mỹ. Trải nghiệm đu dây đu zipline, chèo kayak trên dòng sông Chày xanh biếc và khám phá Động Thiên Đường tráng lệ bậc nhất thế giới.",
      imagePath: "assets/images/hoian_image.webp",
      duration: "3N/2Đ",
      price: 3225000,
      originalPrice: 4125000,
      destinations: ["Phong Nha", "Quảng Bình"],
      includes: ["Vé tàu hỏa khứ hồi khứ hồi", "Resort Phong Nha ven sông", "Vé thuyền & động Phong Nha", "Vé Zipline Sông Chày Hang Tối", "Tất cả bữa ăn"],
      departure: "SGN",
      isPopular: false,
    },
  ];

  for (const tour of tours) {
    await prisma.tourPackage.create({ data: tour });
  }
  console.log(`  Tour Seeding: Created ${tours.length} tour packages.`);

  // --- Schedule Templates ---
  const dalatTemplate = await prisma.scheduleTemplate.create({
    data: {
      name: "Tour Đà Lạt 3N2Đ",
      sourceType: "tour",
      tourPackageId: "tour-dalat-3n2d",
      days: {
        create: [
          {
            dayNumber: 1,
            items: {
              create: [
                {
                  sortOrder: 1,
                  startTime: "08:00",
                  endTime: "09:00",
                  title: "Đón khách và ăn sáng",
                  description: "Xe và HDV đón khách tại điểm hẹn. Dùng điểm tâm sáng.",
                  locationName: "Trung tâm TP.HCM",
                },
                {
                  sortOrder: 2,
                  startTime: "12:00",
                  endTime: "13:00",
                  title: "Ăn trưa và nhận phòng",
                  description: "Dùng cơm trưa tại nhà hàng địa phương, sau đó nhận phòng khách sạn nghỉ ngơi.",
                  locationName: "Khách sạn Mường Thanh Đà Lạt",
                },
                {
                  sortOrder: 3,
                  startTime: "15:00",
                  endTime: "17:30",
                  title: "Tham quan Thác Datanla",
                  description: "Trải nghiệm máng trượt xuyên rừng thông và ngắm vẻ đẹp hùng vĩ của Thác Datanla.",
                  locationName: "Thác Datanla",
                  latitude: 11.9022,
                  longitude: 108.4497,
                },
                {
                  sortOrder: 4,
                  startTime: "18:30",
                  endTime: "20:00",
                  title: "Ăn tối Buffet Rau",
                  description: "Thưởng thức Buffet Rau Léguda đặc sản Đà Lạt.",
                  locationName: "Nhà hàng Léguda",
                }
              ]
            }
          },
          {
            dayNumber: 2,
            items: {
              create: [
                {
                  sortOrder: 1,
                  startTime: "08:00",
                  endTime: "11:30",
                  title: "Chinh phục đỉnh Langbiang",
                  description: "Di chuyển bằng xe Jeep lên đỉnh Langbiang ngắm toàn cảnh Đà Lạt sương mờ.",
                  locationName: "Khu du lịch Langbiang",
                },
                {
                  sortOrder: 2,
                  startTime: "14:00",
                  endTime: "16:00",
                  title: "Chèo thuyền Kayak Hồ Tuyền Lâm",
                  description: "Trải nghiệm chèo thuyền Kayak ngắm hoàng hôn trên Hồ Tuyền Lâm.",
                  locationName: "Hồ Tuyền Lâm",
                },
                {
                  sortOrder: 3,
                  startTime: "18:00",
                  endTime: "21:00",
                  title: "Tiệc BBQ rừng thông",
                  description: "Giao lưu lửa trại và thưởng thức tiệc BBQ giữa rừng thông.",
                  locationName: "Rừng thông Đà Lạt",
                }
              ]
            }
          }
        ]
      }
    }
  });

  const phuquocTemplate = await prisma.scheduleTemplate.create({
    data: {
      name: "Tour Phú Quốc 4N3Đ",
      sourceType: "tour",
      tourPackageId: "tour-phuquoc-4n3d",
      days: {
        create: [
          {
            dayNumber: 1,
            items: {
              create: [
                { sortOrder: 1, startTime: "09:00", endTime: "11:00", title: "Bay đến Phú Quốc", description: "Đón sân bay và di chuyển đến resort.", locationName: "Sân bay Phú Quốc" },
                { sortOrder: 2, startTime: "14:00", endTime: "18:00", title: "Khám phá VinWonders", description: "Vui chơi không giới hạn tại công viên giải trí lớn nhất Việt Nam.", locationName: "VinWonders Phú Quốc" }
              ]
            }
          },
          {
            dayNumber: 2,
            items: {
              create: [
                { sortOrder: 1, startTime: "08:00", endTime: "16:00", title: "Tour 4 Đảo hoang sơ", description: "Đi cano thám hiểm 4 hòn đảo đẹp nhất Nam Đảo, lặn ngắm san hô.", locationName: "Quần đảo An Thới" },
                { sortOrder: 2, startTime: "18:30", endTime: "21:00", title: "Ăn tối chợ đêm", description: "Tự do thưởng thức hải sản tại Chợ Đêm Phú Quốc.", locationName: "Chợ Đêm Phú Quốc" }
              ]
            }
          }
        ]
      }
    }
  });

  const phuquyTemplate = await prisma.scheduleTemplate.create({
    data: {
      name: "Tour Phú Quý 3N2Đ",
      sourceType: "tour",
      tourPackageId: "tour-phuquy-3n2d",
      days: {
        create: [
          {
            dayNumber: 1,
            items: {
              create: [
                { sortOrder: 1, startTime: "07:00", endTime: "10:30", title: "Di chuyển bằng tàu cao tốc", description: "Lên tàu từ cảng Phan Thiết di chuyển ra đảo.", locationName: "Cảng Phan Thiết" },
                { sortOrder: 2, startTime: "11:00", endTime: "12:00", title: "Nhận phòng và nghỉ ngơi", description: "Đến đảo Phú Quý, nhận phòng khách sạn.", locationName: "Đảo Phú Quý" },
                { sortOrder: 3, startTime: "15:00", endTime: "18:00", title: "Khám phá quanh đảo", description: "Dạo biển, đón hoàng hôn trên đỉnh Cao Cát.", locationName: "Núi Cao Cát" }
              ]
            }
          },
          {
            dayNumber: 2,
            items: {
              create: [
                { sortOrder: 1, startTime: "08:00", endTime: "12:00", title: "Cano khám phá Hòn Tranh", description: "Thỏa sức tắm biển và lặn ngắm san hô bằng cano.", locationName: "Hòn Tranh" },
                { sortOrder: 2, startTime: "16:00", endTime: "18:00", title: "Check-in cột cờ chủ quyền", description: "Tham quan cột cờ và chụp ảnh lưu niệm.", locationName: "Cột cờ chủ quyền Phú Quý" },
                { sortOrder: 3, startTime: "19:00", endTime: "21:00", title: "Tiệc BBQ hải sản", description: "Thưởng thức cua Huỳnh Đế và hải sản tươi sống.", locationName: "Nhà hàng hải sản" }
              ]
            }
          },
          {
            dayNumber: 3,
            items: {
              create: [
                { sortOrder: 1, startTime: "08:00", endTime: "09:30", title: "Tham quan Vịnh Triều Dương", description: "Dạo biển, ngắm bình minh trên Vịnh Triều Dương.", locationName: "Vịnh Triều Dương" },
                { sortOrder: 2, startTime: "11:00", endTime: "13:30", title: "Lên tàu về đất liền", description: "Lên tàu cao tốc trở về Phan Thiết, kết thúc chuyến đi.", locationName: "Cảng Phú Quý" }
              ]
            }
          }
        ]
      }
    }
  });

  console.log(`  Schedule Template Seeding: Created 3 templates.`);

  // Create real schedule for trip-7 (Đang diễn ra)
  const d = new Date();
  const dStr = d.toISOString();
  d.setDate(d.getDate() + 1);
  const d2Str = d.toISOString();

  await prisma.tripScheduleDay.create({
    data: {
      tripId: "trip-7",
      dayNumber: 1,
      date: dStr,
      items: {
        create: [
          { sortOrder: 1, startTime: "08:00", endTime: "09:00", title: "Đón khách và ăn sáng", description: "Xe và HDV đón khách tại điểm hẹn.", locationName: "Trung tâm TP.HCM", statusOverride: "completed" },
          { sortOrder: 2, startTime: "12:00", endTime: "13:00", title: "Ăn trưa và nhận phòng", description: "Dùng cơm trưa tại nhà hàng địa phương.", locationName: "Khách sạn Mường Thanh Đà Lạt", statusOverride: "ongoing" },
          { sortOrder: 3, startTime: "15:00", endTime: "17:30", title: "Tham quan Thác Datanla", description: "Trải nghiệm máng trượt xuyên rừng thông.", locationName: "Thác Datanla", statusOverride: "upcoming" }
        ]
      }
    }
  });
  
  await prisma.tripScheduleDay.create({
    data: {
      tripId: "trip-7",
      dayNumber: 2,
      date: d2Str,
      items: {
        create: [
          { sortOrder: 1, startTime: "08:00", endTime: "11:30", title: "Chinh phục đỉnh Langbiang", description: "Di chuyển bằng xe Jeep.", locationName: "Khu du lịch Langbiang", statusOverride: "upcoming" }
        ]
      }
    }
  });

  console.log(`  Trip Schedule Seeding: Created ongoing schedule for trip-7.`);

  console.log("🎉 Seeding completed successfully!");
}

main()
  .catch((e) => {
    console.error("❌ Seeding failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
