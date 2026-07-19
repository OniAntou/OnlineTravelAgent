# Bổ sung lịch trình cho các tour còn thiếu

## Mục tiêu

Hoàn thiện lịch trình mẫu cho năm tour chưa có `ScheduleTemplate`, để mọi tour
trong danh mục đều hiển thị lịch trình thực từ API thay vì rơi vào giao diện dự
phòng. Nội dung phục vụ đồ án nên ngắn gọn, dễ đọc và bám sát mô tả tour.

## Phạm vi

- Bổ sung đúng năm mẫu theo tour (`sourceType: tour`): Hạ Long 2N1Đ, Ninh Bình
  2N1Đ, Sapa 3N2Đ, Phong Nha 3N2Đ và Miền Trung 5N4Đ.
- Mỗi ngày có 2--3 mốc theo thứ tự thời gian, gồm giờ bắt đầu/kết thúc, tiêu đề,
  mô tả ngắn và địa điểm khi hoạt động diễn ra tại một điểm cụ thể.
- Không thay đổi ba mẫu lịch trình hiện có, không tạo lịch trình riêng cho các
  đơn đặt tour đã phát sinh và không thay đổi giao diện.

## Nội dung lịch trình

| Tour | Ngày | Các mốc chính |
| --- | --- | --- |
| Du thuyền Vịnh Hạ Long 5 Sao | 1 | Lên du thuyền và nhận cabin; chèo kayak Hang Luồn; lớp nấu ăn và tiệc tối trên boong. |
|  | 2 | Tập Thái Cực Quyền đón bình minh; dùng bữa sáng, trả cabin và về bến. |
| Hành Trình Tràng An Cổ Kính | 1 | Du ngoạn thuyền Tràng An; ăn trưa đặc sản dê núi; chinh phục Hang Múa. |
|  | 2 | Tham quan chùa Bái Đính; trả phòng và khởi hành về. |
| Khám Phá Sapa Hùng Vĩ Sương Mờ | 1 | Đến Sapa, nhận phòng; khám phá bản Cát Cát; tự do thưởng thức ẩm thực địa phương. |
|  | 2 | Cáp treo chinh phục Fansipan; tham quan, ăn trưa tại khu du lịch; tắm lá thuốc Dao Đỏ. |
|  | 3 | Dạo thị trấn và mua đặc sản; trả phòng, lên xe về. |
| Thám Hiểm Hang Động Phong Nha | 1 | Đến Phong Nha, nhận phòng; xuôi thuyền khám phá động Phong Nha; ăn tối ven sông Son. |
|  | 2 | Zipline và chèo kayak Sông Chày; khám phá Hang Tối; nghỉ ngơi tự do. |
|  | 3 | Tham quan động Thiên Đường; trả phòng và về. |
| Hành Trình Di Sản Miền Trung | 1 | Đến Đà Nẵng, nhận phòng; tham quan bán đảo Sơn Trà; dạo Cầu Rồng buổi tối. |
|  | 2 | Cáp treo Bà Nà Hills; check-in Cầu Vàng; về Đà Nẵng nghỉ ngơi. |
|  | 3 | Di chuyển Hội An; tham quan phố cổ; thả hoa đăng sông Hoài. |
|  | 4 | Di chuyển Huế; tham quan Đại Nội; nghe ca Huế trên sông Hương. |
|  | 5 | Thăm chùa Thiên Mụ; mua đặc sản và khởi hành về. |

## Cách lưu và nạp dữ liệu

Thêm một script seed chuyên biệt, có thể chạy lặp lại an toàn. Script đọc danh
sách năm tour, kiểm tra `ScheduleTemplate` theo cặp `sourceType: tour` và
`tourPackageId`, rồi chỉ tạo mẫu còn thiếu cùng các ngày và mốc của mẫu đó.

Không dùng `npm run db:seed` cho việc này vì seed tổng hiện xoá toàn bộ dữ liệu
trước khi tạo lại. Script chuyên biệt được thêm một lệnh npm riêng và sẽ là
nguồn dữ liệu có thể tái lập cho cả môi trường mới lẫn cơ sở dữ liệu hiện tại.

## Luồng dữ liệu và lỗi

Khi ứng dụng gọi `GET /api/tours/:id/schedule`, API đọc mẫu theo tour đã có và
trả về các ngày/mốc theo thứ tự. Script báo rõ tour nào được tạo, tour nào đã
có mẫu, và dừng với lỗi nếu ID tour không tồn tại; vì vậy không thể tạo mẫu mồ
côi hoặc ghi đè lịch trình hiện hữu.

## Kiểm thử và xác minh

- Thêm kiểm thử cho dữ liệu seed: đủ năm ID tour, số ngày khớp `duration`, mốc
  trong ngày được sắp tăng dần và không có tour trùng.
- Chạy kiểm thử backend liên quan đến lịch trình và build TypeScript.
- Chạy script một lần để nạp năm mẫu, rồi truy vấn lại: danh mục có tám tour và
  tám mẫu lịch trình; chạy lần hai không tạo thêm dữ liệu.
- Kiểm tra `flutter test` để bảo đảm UI vẫn đọc lịch trình từ API bình thường.

## Ngoài phạm vi

Không thêm định vị GPS vào các mốc mới, không tự động đánh dấu tiến độ, không
thay đổi giá/bao gồm của tour và không sửa lịch trình của các chuyến đã đặt.
