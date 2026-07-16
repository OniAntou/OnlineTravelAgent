# Thiết kế: đồng bộ ảnh bằng Supabase Storage

**Ngày:** 2026-07-17
**Trạng thái:** Đã hoàn tất: bucket, source, kiểm thử và smoke upload thật.

## Mục tiêu

Các ảnh được tải lên từ Admin và Partner phải dùng chung giữa mọi máy chạy ứng dụng. Database tiếp tục chỉ lưu chuỗi `imagePath`; không lưu blob ảnh trong PostgreSQL.

## Phương án được chọn

Tạo bucket Supabase Storage công khai tên `travel-media` dành cho ảnh catalogue (địa điểm, khách sạn, phòng, logo hãng bay và tour).

- Người dùng chỉ có quyền đọc ảnh qua URL công khai của bucket.
- Chỉ backend được tải ảnh lên; service-role key chỉ nằm trong `backend/.env`, không đưa vào Flutter hay trang Admin/Partner.
- Backend trả về URL HTTPS tuyệt đối trong cùng contract `{ url }` của hai endpoint upload hiện có.
- Flutter đã nhận URL HTTPS; Admin/Partner sẽ hiển thị trực tiếp URL này thay vì ghép thêm base API.
- Asset bundled và URL cũ dạng `/uploads/...` vẫn được giữ tương thích. Không tự di chuyển hoặc xóa ảnh cũ trong thay đổi này.

## Luồng dữ liệu

1. Admin hoặc Partner chọn ảnh từ form hiện có.
2. Trình duyệt gửi `multipart/form-data` tới endpoint upload đã được bảo vệ bởi Basic Auth hoặc Partner JWT.
3. Multer kiểm tra một file ảnh, tối đa 10 MB; backend kiểm tra MIME type/đuôi file và tạo object key không đoán được.
4. Backend dùng Supabase service-role để ghi object vào `travel-media` và trả public URL.
5. Form lưu URL đó vào `imagePath` qua các API create/update đang có; PostgreSQL trên Supabase đồng bộ giá trị này cho mọi máy.
6. Flutter/Admin/Partner dùng URL tuyệt đối để hiển thị ảnh từ Storage.

## Bảo mật và lỗi

- Bucket chỉ chấp nhận JPEG, PNG, GIF và WebP; tài liệu không nằm trong phạm vi endpoint ảnh này.
- Không cấp policy upload/xóa cho `anon` hoặc `authenticated`; service-role ở backend bỏ qua RLS của Storage.
- Key mới cần có: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_STORAGE_BUCKET=travel-media`. Chúng được liệt kê trong `.env.example` bằng placeholder, còn giá trị thật chỉ ở `.env` đã bị Git ignore.
- Lỗi cấu hình, lỗi upload hoặc file không hợp lệ phải trả JSON an toàn; không trả key hay chi tiết nội bộ.
- Không xóa object khi người dùng thay ảnh/xóa bản ghi trong đợt này vì API hiện không liên kết asset với một bản ghi trước lúc form được lưu. Các object tải lên nhưng không dùng sẽ được coi là orphan và có thể dọn sau bằng công việc riêng.

## Phạm vi code và kiểm chứng

- Thêm module Storage độc lập ở backend và endpoint upload dùng chung cho Admin/Partner.
- Điều chỉnh middleware upload chỉ cho ảnh và dùng bộ nhớ tạm thay vì ghi file cục bộ.
- Sửa preview Admin/Partner để hỗ trợ URL tuyệt đối mà vẫn hỗ trợ path cũ.
- Thêm unit/API test cho validate upload, URL trả về và lỗi Storage; giữ test Flutter `AppImage` chứng minh ảnh HTTPS vẫn hiển thị.
- Xác minh bucket, MIME/size configuration và upload thật tới Supabase; chạy `npm run build`, backend test và Flutter test/analyze phù hợp.

## Không thuộc phạm vi

- Không chuyển các asset seed có sẵn lên cloud.
- Không thay đổi schema Prisma hay migration database.
- Không đưa backend lên cloud; các máy vẫn phải chạy backend local để upload.
- Không thay đổi phân quyền CRUD Admin/Partner hiện tại.
