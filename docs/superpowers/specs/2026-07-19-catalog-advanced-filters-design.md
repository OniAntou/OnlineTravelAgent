# Bộ lọc catalog nâng cao (tối giản) — thiết kế

**Trạng thái:** Đã duyệt để lập kế hoạch, 2026-07-19

## Mục tiêu

Làm cho danh sách khách sạn và tour dễ thu hẹp theo dữ liệu thực tế mà không
biến đồ án thành một search engine server-side. Bộ lọc chạy cục bộ trên payload
bootstrap đã có; thao tác không tạo API, migration, cache mới hay mutation.

## Bối cảnh và giới hạn dữ liệu

Màn hình hiện có đã có tìm kiếm, một số sort và chip thành phố cố định. Catalog
hiện tại nhỏ (9 khách sạn, 8 tour), rating của khách sạn chưa đủ tin cậy để làm
filter/sort, còn amenities, điểm đến và dịch vụ tour hầu hết là giá trị đơn lẻ.
Vì vậy không đưa rating, amenities, ngày khởi hành hay hướng dẫn viên vào bộ
lọc: các lựa chọn này sẽ tạo cảm giác có chức năng nhưng ít hoặc không có giá
trị lọc thật.

## Phương án được chọn

Giữ việc lọc ở Flutter, tách logic thuần theo từng feature thay vì xây một
generic filter framework. `HotelsScreen` và `ToursScreen` giữ state filter
riêng, gọi hàm pure để lọc/sort mỗi lần bootstrap hoặc người dùng đổi điều
kiện. Cách này giữ UI phản hồi ngay, không làm ảnh hưởng contract REST/cache
hiện có và đủ cho quy mô dữ liệu hiện tại.

## Tiêu chí lọc và sắp xếp

### Khách sạn

| Nhóm | Hành vi |
|---|---|
| Từ khóa | So khớp không phân biệt hoa thường với tên, location hoặc address. |
| Khu vực | Chọn một giá trị location đang có trong catalog, hoặc tất cả. Không còn danh sách thành phố hard-code. |
| Giá tối đa | Slider từ 0 đến mức giá cao nhất của catalog; `null` nghĩa là không giới hạn. |
| Còn phòng | Khi bật, chỉ giữ hotel có ít nhất một `Room` trong bootstrap. |
| Sắp xếp | Gợi ý/catalog order, giá thấp-cao, giá cao-thấp, nhiều lựa chọn phòng. |

### Tour

| Nhóm | Hành vi |
|---|---|
| Từ khóa | So khớp không phân biệt hoa thường với tên, điểm khởi hành hoặc các destination. |
| Điểm khởi hành | Chọn một mã departure đang có (hiện là `HAN`/`SGN`), hoặc tất cả. |
| Thời lượng | Tất cả, 2–3 ngày, hoặc từ 4 ngày; parser đọc số trước `N` trong format hiện tại như `3N/2Đ`. Giá trị không parse được chỉ xuất hiện ở lựa chọn tất cả. |
| Giá tối đa | Slider từ 0 đến mức giá tour cao nhất; `null` nghĩa là không giới hạn. |
| Nổi bật | Khi bật, chỉ giữ `isPopular = true`. |
| Sắp xếp | Gợi ý (popular trước, sau đó catalog order), giá thấp-cao, giá cao-thấp, ngắn-dài, dài-ngắn. |

## Trải nghiệm UI

Nút `tune` hiện có mở bottom sheet **Bộ lọc & sắp xếp** thay cho sheet chỉ có
sort. Sheet có các section theo từng catalog, slider giá có nhãn VND, lựa chọn
chip một/many phù hợp và hai action rõ ràng: **Đặt lại** và **Áp dụng**. Khi
đóng bằng Áp dụng, màn hình hiển thị số kết quả cùng chip tóm tắt các điều kiện
đang hoạt động; chip có thể được bỏ từng cái, và empty state xóa cả từ khóa,
filter lẫn sort về mặc định.

Giữ màu xanh, spacing, bo góc và Material controls hiện có. Không thêm tab,
modal lồng nhau, lưu filter vào local storage hay animation mới. `Wrap`/scroll
an toàn trên màn hẹp phải được dùng để không lặp lỗi overflow bố cục trước đó.

## Cấu trúc code

| File | Trách nhiệm |
|---|---|
| `lib/features/hotels/application/hotel_filtering.dart` | `HotelCatalogFilter`, enum sort và hàm pure lọc/sort hotel. |
| `lib/features/tours/application/tour_filtering.dart` | `TourCatalogFilter`, enum sort, parser duration và hàm pure lọc/sort tour. |
| `lib/features/hotels/presentation/widgets/hotel_filter_sheet.dart` | Draft UI chọn bộ lọc hotel; chỉ trả state đã áp dụng. |
| `lib/features/tours/presentation/widgets/tour_filter_sheet.dart` | Draft UI chọn bộ lọc tour; chỉ trả state đã áp dụng. |
| `hotels_screen.dart`, `tours_screen.dart` | Giữ filter đã áp dụng, render chip summary/kết quả và gọi pure filter. |

Sheet làm việc với bản nháp. Nhấn Đặt lại chỉ reset bản nháp; nhấn Áp dụng mới
đổi state của màn hình. Khi người dùng bỏ một chip hoặc reset empty state,
state applied đổi trực tiếp. Điều này tránh list nhảy liên tục khi đang kéo
slider hoặc đang chọn nhiều chip.

## Kiểm thử

- Test thuần hotel: từ khóa, location động, max price, còn phòng và từng sort.
- Test thuần tour: từ khóa/destination, departure, duration parser/bucket,
  popular, max price và từng sort.
- Widget test một sheet: state không làm đổi list cho tới khi nhấn Áp dụng,
  và reset trả về default.
- Chạy `flutter analyze` và `flutter test` toàn bộ. Không cần backend test,
  migration hay deploy vì contract server không đổi.

## Ngoài phạm vi

- Query parameter/filter/sort ở Express/Prisma hoặc thay index database.
- Rating/amenity filter cho hotel, filter theo ngày/hướng dẫn viên/bao gồm cho
  tour, vì catalog hiện chưa cung cấp dữ liệu đủ ổn định hoặc có sức phân loại.
- Lưu/persist filter giữa các lần mở app, phân trang, đề xuất cá nhân hóa hoặc
  thay đổi dữ liệu catalog.
