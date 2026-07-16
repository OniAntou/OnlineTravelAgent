# Kế hoạch triển khai

Thư mục này lưu kế hoạch theo thời điểm cho các thay đổi có nhiều bước, migration hoặc cần checklist kiểm chứng. Mỗi kế hoạch phải nêu rõ phạm vi, các file/ràng buộc liên quan, bước thực hiện và cách xác minh.

## Ranh giới

- `architecture/` mô tả thiết kế và contract đang có hiệu lực.
- `workflows/` mô tả luồng nghiệp vụ và quy trình vận hành lặp lại.
- `plans/` ghi lại cách triển khai một thay đổi cụ thể; không thay thế source of truth trong code, test, architecture hoặc workflows.

Khi kế hoạch hoàn tất, giữ lại như một hồ sơ triển khai ngắn gọn và cập nhật các tài liệu kiến trúc/workflow bị ảnh hưởng trong cùng thay đổi.

## Kế hoạch hiện có

- [Triển khai quản lý vòng đời ảnh Supabase Storage, 2026-07-17 — hoàn tất](2026-07-17-image-lifecycle-management-implementation.md)
- [Thiết kế quản lý vòng đời ảnh Supabase Storage, 2026-07-17 — đã triển khai](2026-07-17-image-lifecycle-management-design.md)
- [Triển khai đồng bộ ảnh bằng Supabase Storage, 2026-07-17](2026-07-17-supabase-storage-images-implementation.md)
- [Thiết kế đồng bộ ảnh bằng Supabase Storage, 2026-07-17](2026-07-17-supabase-storage-images-design.md)
- [Nâng cấp dependency an toàn, 2026-07-17](2026-07-17-safe-dependency-upgrades.md)
- [Tối ưu runtime và luồng dữ liệu — thiết kế, 2026-07-16](2026-07-16-runtime-and-dataflow-optimization.md)
- [Tối ưu runtime và luồng dữ liệu — kế hoạch triển khai, 2026-07-16](2026-07-16-runtime-and-dataflow-optimization-plan.md)
