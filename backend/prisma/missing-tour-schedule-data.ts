export type MissingTourScheduleTemplate = {
  tourPackageId: string;
  name: string;
  days: Array<{
    dayNumber: number;
    title: string;
    items: Array<{
      sortOrder: number;
      startTime: string;
      endTime: string;
      title: string;
      description: string;
      locationName?: string;
    }>;
  }>;
};

export const missingTourScheduleTemplates: MissingTourScheduleTemplate[] = [
  {
    tourPackageId: "tour-halong-2n1d",
    name: "Du thuyền Vịnh Hạ Long 5 Sao 2N1Đ",
    days: [
      { dayNumber: 1, title: "Khởi hành và khám phá vịnh", items: [
        { sortOrder: 1, startTime: "11:30", endTime: "13:00", title: "Lên du thuyền và nhận cabin", description: "Làm thủ tục, dùng bữa trưa và nhận cabin.", locationName: "Cảng Tuần Châu" },
        { sortOrder: 2, startTime: "14:30", endTime: "16:30", title: "Chèo kayak Hang Luồn", description: "Khám phá hang nước và các đảo đá vôi.", locationName: "Hang Luồn" },
        { sortOrder: 3, startTime: "18:00", endTime: "21:00", title: "Lớp nấu ăn và tiệc tối", description: "Tham gia lớp nấu ăn trên boong và dùng bữa tối hải sản.", locationName: "Du thuyền" },
      ] },
      { dayNumber: 2, title: "Đón bình minh và về bến", items: [
        { sortOrder: 1, startTime: "06:00", endTime: "07:00", title: "Tập Thái Cực Quyền", description: "Đón bình minh trên vịnh cùng bài tập nhẹ.", locationName: "Sundeck du thuyền" },
        { sortOrder: 2, startTime: "08:00", endTime: "11:30", title: "Dùng bữa sáng và trả cabin", description: "Dùng bữa sáng, trả cabin và di chuyển về bến.", locationName: "Cảng Tuần Châu" },
      ] },
    ],
  },
  {
    tourPackageId: "tour-ninhbinh-2n1d",
    name: "Hành Trình Tràng An Cổ Kính 2N1Đ",
    days: [
      { dayNumber: 1, title: "Tràng An và Hang Múa", items: [
        { sortOrder: 1, startTime: "08:00", endTime: "11:30", title: "Du ngoạn Tràng An", description: "Đi thuyền nan qua các hang động và núi đá vôi.", locationName: "Quần thể danh thắng Tràng An" },
        { sortOrder: 2, startTime: "12:00", endTime: "13:30", title: "Ăn trưa đặc sản dê núi", description: "Thưởng thức ẩm thực địa phương.", locationName: "Ninh Bình" },
        { sortOrder: 3, startTime: "15:00", endTime: "17:30", title: "Chinh phục Hang Múa", description: "Leo núi ngắm toàn cảnh Tam Cốc.", locationName: "Hang Múa" },
      ] },
      { dayNumber: 2, title: "Chùa Bái Đính và trở về", items: [
        { sortOrder: 1, startTime: "08:00", endTime: "11:00", title: "Tham quan chùa Bái Đính", description: "Viếng quần thể chùa lớn và tìm hiểu kiến trúc.", locationName: "Chùa Bái Đính" },
        { sortOrder: 2, startTime: "13:00", endTime: "16:30", title: "Trả phòng và khởi hành về", description: "Kết thúc hành trình Ninh Bình.", locationName: "Ninh Bình" },
      ] },
    ],
  },
  {
    tourPackageId: "tour-sapa-3n2d",
    name: "Khám Phá Sapa Hùng Vĩ Sương Mờ 3N2Đ",
    days: [
      { dayNumber: 1, title: "Đến Sapa và bản Cát Cát", items: [
        { sortOrder: 1, startTime: "12:00", endTime: "14:00", title: "Đến Sapa và nhận phòng", description: "Ổn định chỗ ở, nghỉ ngơi sau hành trình.", locationName: "Thị trấn Sapa" },
        { sortOrder: 2, startTime: "15:00", endTime: "17:30", title: "Khám phá bản Cát Cát", description: "Tìm hiểu văn hóa người H'Mông và chụp ảnh.", locationName: "Bản Cát Cát" },
        { sortOrder: 3, startTime: "19:00", endTime: "21:00", title: "Thưởng thức ẩm thực địa phương", description: "Tự do dạo phố và dùng bữa tối.", locationName: "Thị trấn Sapa" },
      ] },
      { dayNumber: 2, title: "Chinh phục Fansipan", items: [
        { sortOrder: 1, startTime: "08:00", endTime: "11:30", title: "Cáp treo chinh phục Fansipan", description: "Ngắm mây núi và chạm đỉnh Fansipan.", locationName: "Khu du lịch Sun World Fansipan Legend" },
        { sortOrder: 2, startTime: "12:00", endTime: "14:00", title: "Tham quan và ăn trưa", description: "Nghỉ chân, dùng bữa tại khu du lịch.", locationName: "Fansipan" },
        { sortOrder: 3, startTime: "16:00", endTime: "18:00", title: "Tắm lá thuốc Dao Đỏ", description: "Trải nghiệm thư giãn truyền thống.", locationName: "Sapa" },
      ] },
      { dayNumber: 3, title: "Tạm biệt Sapa", items: [
        { sortOrder: 1, startTime: "08:00", endTime: "10:00", title: "Dạo thị trấn và mua đặc sản", description: "Mua quà lưu niệm trước khi rời Sapa.", locationName: "Chợ Sapa" },
        { sortOrder: 2, startTime: "11:00", endTime: "15:00", title: "Trả phòng và lên xe về", description: "Kết thúc chương trình.", locationName: "Thị trấn Sapa" },
      ] },
    ],
  },
  {
    tourPackageId: "tour-phongnha-3n2d",
    name: "Thám Hiểm Hang Động Phong Nha 3N2Đ",
    days: [
      { dayNumber: 1, title: "Đến Phong Nha và khám phá động", items: [
        { sortOrder: 1, startTime: "11:30", endTime: "13:30", title: "Đến Phong Nha và nhận phòng", description: "Dùng bữa trưa, nhận phòng và nghỉ ngơi.", locationName: "Phong Nha" },
        { sortOrder: 2, startTime: "14:30", endTime: "17:00", title: "Thám hiểm động Phong Nha", description: "Xuôi thuyền sông Son vào hang động.", locationName: "Động Phong Nha" },
        { sortOrder: 3, startTime: "18:30", endTime: "20:30", title: "Ăn tối ven sông Son", description: "Dùng bữa tối và tự do nghỉ ngơi.", locationName: "Sông Son" },
      ] },
      { dayNumber: 2, title: "Sông Chày - Hang Tối", items: [
        { sortOrder: 1, startTime: "08:00", endTime: "11:30", title: "Zipline và chèo kayak Sông Chày", description: "Trải nghiệm hoạt động ngoài trời trên sông.", locationName: "Sông Chày" },
        { sortOrder: 2, startTime: "13:30", endTime: "16:00", title: "Khám phá Hang Tối", description: "Đi bộ, tắm bùn và khám phá hang.", locationName: "Hang Tối" },
        { sortOrder: 3, startTime: "18:00", endTime: "20:00", title: "Nghỉ ngơi tự do", description: "Tự do dạo chơi tại Phong Nha.", locationName: "Phong Nha" },
      ] },
      { dayNumber: 3, title: "Động Thiên Đường và trở về", items: [
        { sortOrder: 1, startTime: "08:00", endTime: "11:00", title: "Tham quan động Thiên Đường", description: "Chiêm ngưỡng hệ thống thạch nhũ trong hang.", locationName: "Động Thiên Đường" },
        { sortOrder: 2, startTime: "12:00", endTime: "16:00", title: "Trả phòng và khởi hành về", description: "Kết thúc hành trình Phong Nha.", locationName: "Phong Nha" },
      ] },
    ],
  },
  {
    tourPackageId: "tour-mientrung-5n4d",
    name: "Hành Trình Di Sản Miền Trung 5N4Đ",
    days: [
      { dayNumber: 1, title: "Đà Nẵng chào đón", items: [
        { sortOrder: 1, startTime: "11:30", endTime: "14:00", title: "Đến Đà Nẵng và nhận phòng", description: "Dùng bữa trưa, nhận phòng khách sạn.", locationName: "Đà Nẵng" },
        { sortOrder: 2, startTime: "15:00", endTime: "17:30", title: "Tham quan bán đảo Sơn Trà", description: "Ngắm biển và tham quan chùa Linh Ứng.", locationName: "Bán đảo Sơn Trà" },
        { sortOrder: 3, startTime: "19:00", endTime: "21:00", title: "Dạo Cầu Rồng buổi tối", description: "Khám phá thành phố bên sông Hàn.", locationName: "Cầu Rồng" },
      ] },
      { dayNumber: 2, title: "Bà Nà Hills", items: [
        { sortOrder: 1, startTime: "08:00", endTime: "11:30", title: "Cáp treo Bà Nà Hills", description: "Di chuyển bằng cáp treo và tham quan khu du lịch.", locationName: "Bà Nà Hills" },
        { sortOrder: 2, startTime: "12:00", endTime: "14:00", title: "Check-in Cầu Vàng", description: "Tham quan Cầu Vàng và dùng bữa trưa.", locationName: "Cầu Vàng" },
        { sortOrder: 3, startTime: "15:00", endTime: "17:30", title: "Về Đà Nẵng nghỉ ngơi", description: "Trở về khách sạn sau chương trình.", locationName: "Đà Nẵng" },
      ] },
      { dayNumber: 3, title: "Phố cổ Hội An", items: [
        { sortOrder: 1, startTime: "09:00", endTime: "11:00", title: "Di chuyển đến Hội An", description: "Khởi hành từ Đà Nẵng đến phố cổ.", locationName: "Hội An" },
        { sortOrder: 2, startTime: "14:00", endTime: "17:00", title: "Tham quan phố cổ", description: "Khám phá Chùa Cầu và các ngôi nhà cổ.", locationName: "Phố cổ Hội An" },
        { sortOrder: 3, startTime: "19:00", endTime: "20:30", title: "Thả hoa đăng sông Hoài", description: "Trải nghiệm không gian đèn lồng về đêm.", locationName: "Sông Hoài" },
      ] },
      { dayNumber: 4, title: "Cố đô Huế", items: [
        { sortOrder: 1, startTime: "08:00", endTime: "11:00", title: "Di chuyển đến Huế", description: "Khởi hành qua đèo Hải Vân đến cố đô.", locationName: "Huế" },
        { sortOrder: 2, startTime: "14:00", endTime: "17:00", title: "Tham quan Đại Nội", description: "Khám phá kiến trúc cung đình triều Nguyễn.", locationName: "Đại Nội Huế" },
        { sortOrder: 3, startTime: "19:00", endTime: "20:30", title: "Nghe ca Huế trên sông Hương", description: "Thưởng thức chương trình nghệ thuật truyền thống.", locationName: "Sông Hương" },
      ] },
      { dayNumber: 5, title: "Tạm biệt miền Trung", items: [
        { sortOrder: 1, startTime: "08:00", endTime: "10:00", title: "Thăm chùa Thiên Mụ", description: "Tham quan ngôi chùa cổ bên sông Hương.", locationName: "Chùa Thiên Mụ" },
        { sortOrder: 2, startTime: "10:30", endTime: "15:00", title: "Mua đặc sản và khởi hành về", description: "Kết thúc hành trình di sản miền Trung.", locationName: "Huế" },
      ] },
    ],
  },
];
