# Tab Đã huỷ trong Chuyến đi của tôi

## Mục tiêu

Tách những booking có trạng thái `CANCELLED` khỏi Lịch sử chuyến đi, để người
dùng nhận biết rõ chuyến hoàn tất và chuyến đã huỷ.

## Giao diện

Màn hình **Chuyến đi của tôi** có bốn tab theo thứ tự: **Đang diễn ra**,
**Sắp tới**, **Lịch sử** và **Đã huỷ**. Tab bar dùng cuộn ngang trên màn hình
hẹp để nhãn không bị cắt hoặc ép chữ. Danh sách Đã huỷ tái sử dụng thẻ chuyến
đi và trạng thái đỏ sẵn có; không thêm màn hình hay thao tác mới.

## Phân loại dữ liệu

- `ongoingTripsProvider` giữ các chuyến `ongoing`.
- `upcomingTripsProvider` giữ các chuyến sắp tới hoặc chờ thanh toán.
- `historyTripsProvider` chỉ giữ `completed` và bản ghi legacy `unknown` đã qua
  thời điểm; không còn chứa `cancelled`.
- Provider mới `cancelledTripsProvider` chỉ giữ `TripStatus.cancelled`.

Việc phân loại xảy ra trên state `tripsProvider` đã đồng bộ từ API, nên không
thay đổi Prisma, API, offline schema hoặc logic huỷ booking.

## Lỗi và kiểm thử

Danh sách trống tiếp tục dùng empty state hiện có. Bổ sung kiểm thử provider để
xác nhận chuyến cancelled chỉ xuất hiện tại provider mới và không còn trong
Lịch sử. Chạy Flutter test và analyze sau thay đổi.

## Ngoài phạm vi

Không thay đổi quyền huỷ, hoàn tiền, thông báo, trạng thái backend hay nội dung
chi tiết của một chuyến đã huỷ.
