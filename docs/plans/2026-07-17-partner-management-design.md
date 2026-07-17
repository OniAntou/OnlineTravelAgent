# Partner Management Design

## Goal

Thêm mục **Đối tác** riêng trong trang Admin để quản trị đầy đủ các tài khoản có `User.role = PARTNER`, không tạo bảng dữ liệu mới và không làm lẫn với danh sách người dùng thông thường.

## Current model

`User` là nguồn dữ liệu duy nhất cho tài khoản. Role `PARTNER` được dùng bởi middleware Partner API; một partner sở hữu `Hotel` và `TourPackage` qua `partnerId`. Mỗi hotel có các room riêng. Admin đã có Basic Auth, còn Partner API xác thực bằng JWT của user có role `PARTNER` hoặc `ADMIN`.

## Admin capability

Mục Đối tác sẽ có một trang riêng trong sidebar Admin, cùng mẫu danh sách hiện tại. Mỗi dòng hiển thị tên, email, ngày tạo, số khách sạn và số tour mà đối tác đang sở hữu.

Admin có thể:

- Tạo trực tiếp tài khoản Partner; tài khoản mới luôn có role `PARTNER`.
- Chuyển một user hiện có thành Partner.
- Chỉnh sửa tên, email và tùy chọn đặt lại mật khẩu của Partner.
- Thu hồi role Partner. Việc này giữ tài khoản nhưng xoá toàn bộ hotel, room và tour do họ sở hữu.
- Xoá hoàn toàn Partner. Việc này xoá account cùng toàn bộ catalog do họ sở hữu.

Trang Người dùng giữ nguyên chức năng hiện có, đồng thời có hành động **Cấp quyền đối tác** cho user role `USER`. User đã là Partner không được tạo lại qua form User.

## API design

Các route nằm dưới `/api/admin`, được bảo vệ bởi Basic Auth như các API Admin khác.

| Method | Path | Behaviour |
|---|---|---|
| GET | `/partners` | Trả các user role `PARTNER`, kèm `hotelsCount` và `toursCount`. |
| POST | `/partners` | Tạo Partner từ `name`, `email`, `password`; role được server cố định là `PARTNER`. |
| PUT | `/partners/:id` | Cập nhật `name`, `email` và chỉ hash/đổi password khi password được gửi. Chỉ nhận user đang là Partner. |
| POST | `/users/:id/promote-partner` | Chuyển user role `USER` sang `PARTNER`; trả `409` nếu user đã là Partner. |
| POST | `/partners/:id/demote` | Xoá catalog thuộc sở hữu rồi chuyển role thành `USER`. |
| DELETE | `/partners/:id` | Xoá catalog thuộc sở hữu và account Partner. |

Validation dùng Zod. Tất cả thao tác theo id không tìm thấy, hoặc id không có role phù hợp, trả `404`. Email trùng vẫn dùng lỗi unique hiện hữu của API.

## Deletion and ownership rules

Thu hồi quyền và xoá Partner đều dùng chung một service cleanup trong Admin. Service này đọc toàn bộ image URL đang được quản lý trước khi ghi database; thực hiện phần database trong transaction; chỉ dọn Supabase Storage sau khi transaction thành công.

Catalog cleanup gồm:

1. Xoá ScheduleTemplate của các tour thuộc Partner.
2. Xoá Room của tất cả hotel thuộc Partner.
3. Xoá Hotel và TourPackage của Partner.
4. Xoá các ảnh catalog/room/tour bằng `deleteManagedPublicImages` sau transaction.

Khi xoá hẳn account, cleanup xoá review của user trước. Sau đó, quan hệ `onDelete: Cascade` của `User` xoá refresh token, document, favorite và trip phụ thuộc. Khi chỉ thu hồi role, dữ liệu cá nhân của user được giữ lại; chỉ catalog Partner bị xoá.

## UI and data flow

`navigate('partners')` gọi `loadPartners()`. Hàm này lấy GET `/api/admin/partners` và render trạng thái rỗng hoặc danh sách như các trang catalog. Form Partner dùng cho tạo và chỉnh sửa; phần password khi edit để trống nghĩa là giữ mật khẩu cũ.

Ở trang Users, nút cấp Partner gọi POST `/api/admin/users/:id/promote-partner`, tải lại Users và Partners sau khi thành công. Các hành động thu hồi/xoá trong trang Partners đều có confirm dialog nêu rõ catalog sẽ bị xoá.

## Error handling and verification

- Backend trả lỗi có nghĩa khi payload không hợp lệ, role không đúng, email trùng hoặc user không tồn tại.
- UI hiển thị toast của response và không thay đổi danh sách khi request thất bại.
- Test route/controller kiểm tra list chỉ trả Partner, create đúng role, promote, update password tùy chọn, demote dọn catalog và delete dọn catalog + ảnh đúng thứ tự database trước storage.
- Browser smoke test kiểm tra sidebar, danh sách rỗng và modal Partner xuất hiện; toàn bộ backend test/build/schema validation tiếp tục pass.

## Out of scope

- Chuyển quyền sở hữu catalog sang Partner khác.
- Quy trình xét duyệt/đơn đăng ký Partner mới.
- Thay đổi phân quyền JWT ngoài role `PARTNER` hiện có.
