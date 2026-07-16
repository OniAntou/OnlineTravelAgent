# Thiết kế: quản lý vòng đời ảnh Supabase Storage

**Ngày:** 2026-07-17
**Trạng thái:** Đã triển khai và kiểm chứng

## Mục tiêu

Giải phóng ảnh Supabase Storage không còn được catalog sử dụng khi Admin hoặc Partner thay ảnh, xóa tài nguyên, hoặc xóa khách sạn kèm các phòng của nó. Không thay đổi schema Prisma, API payload hay quyền CRUD hiện có.

## Phạm vi được chọn

- Thay ảnh: sau khi record được cập nhật thành công, xóa ảnh Storage cũ nếu URL đã thay đổi.
- Xóa record: sau khi transaction database thành công, xóa ảnh Storage đang được record tham chiếu.
- Xóa khách sạn: thu thập ảnh khách sạn và tất cả ảnh phòng trước transaction, sau đó xóa từng ảnh Storage sau commit.
- Áp dụng cho `Destination.imagePath`, `Hotel.imagePath`, `Room.imagePath`, `TourPackage.imagePath` và `Flight.airlineLogo` trong cả Admin/Partner nơi có quyền thao tác.
- Sửa Partner `createTour` để nhận và lưu `imagePath` từ form thay vì luôn ghi placeholder.

## Ranh giới an toàn

Chỉ URL thuộc đúng origin `SUPABASE_URL`, endpoint public-object và bucket `SUPABASE_STORAGE_BUCKET` mới được coi là ảnh do hệ thống quản lý. Không xóa asset đóng gói, URL ngoài, `/uploads/...` cũ, chuỗi rỗng hoặc URL sai định dạng.

Object sẽ bị xóa sau khi database transaction đã commit. Nếu xóa Storage thất bại, API CRUD vẫn thành công và backend ghi cảnh báo an toàn; ảnh có thể còn orphan nhưng dữ liệu nghiệp vụ không bị rollback hoặc trỏ tới ảnh đã mất.

Đợt này không giải quyết ảnh được upload nhưng người dùng đóng form trước khi lưu. Việc dọn các object chưa từng được tham chiếu cần media ledger hoặc tác vụ quét riêng, nên được tách thành thay đổi sau.

## Luồng xử lý

1. Controller đọc record hiện tại (và rooms khi xóa hotel) để giữ danh sách URL cũ.
2. Controller thực hiện update/delete và transaction Prisma hiện có.
3. Sau khi Prisma thành công, controller gọi Storage service với URL cũ không còn được record tham chiếu.
4. Storage service bỏ qua URL ngoài phạm vi; với URL hợp lệ, gọi Storage API `remove` bằng service-role key.
5. Lỗi Storage được log và không đổi response CRUD thành lỗi; client nhận entity mới hoặc `{ ok: true }` như contract hiện tại.

## Kiểm chứng

- Unit test parser chỉ chấp nhận URL `travel-media` của project hiện tại.
- Unit/API test xác nhận Admin/Partner thay ảnh và xóa resource yêu cầu xóa đúng object cũ.
- Test xác nhận lỗi Storage không làm update/delete database thất bại.
- Test Partner tạo tour lưu URL ảnh đã upload.
- Chạy backend build/test, Flutter regression, và smoke upload → cập nhật → xóa trên Supabase; cuối cùng kiểm object không còn trong bucket.

## Không thuộc phạm vi

- Không làm gallery/thư viện ảnh UI hoặc upload nhiều ảnh cho một record.
- Không thay đổi RLS, bucket public-read, database migration hay quyền Admin/Partner.
- Không xóa ảnh local legacy hoặc asset bundled.

## Kết quả triển khai

Triển khai hoàn tất ngày 2026-07-17. Backend chỉ xóa object `travel-media` có URL public đúng project sau khi thao tác Prisma thành công; lỗi cleanup không làm CRUD thất bại. Luồng cloud upload A → lưu record → thay bằng B → xóa record đã được kiểm chứng trực tiếp: A biến mất sau update, B tồn tại trước delete và biến mất sau delete.
