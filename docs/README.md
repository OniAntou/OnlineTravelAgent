# Tài liệu kỹ thuật OnlineTravelAgent

Thư mục này là bản đồ kỹ thuật của dự án OnlineTravelAgent. Nó mô tả hệ thống đang có trong source tree, không phải một bản review hay danh sách đề xuất refactor.

## Cách đọc

Đọc theo thứ tự sau khi mới tiếp quản dự án:

1. [Tổng quan kiến trúc](architecture/README.md) để nắm các thành phần và ranh giới trách nhiệm.
2. [Kiến trúc Flutter](architecture/mobile-client.md) để làm việc với mobile app.
3. [Kiến trúc backend và API](architecture/backend-and-api.md) để làm việc với server.
4. [Dữ liệu, bảo mật và tích hợp](architecture/data-security-and-integrations.md) trước khi sửa schema, auth, payment hay upload.
5. [Các workflow nghiệp vụ](workflows/product-journeys.md) để hiểu luồng người dùng đầu cuối.
6. [Đồng bộ và realtime](workflows/sync-and-realtime.md) trước khi thay cache, offline hoặc Socket.IO.
7. [Phát triển và kiểm thử](workflows/development-and-quality.md) để dựng môi trường và chạy kiểm chứng.
8. [Vận hành và phát hành](workflows/operations-and-release.md) trước khi deploy.
9. [Kế hoạch triển khai](plans/README.md) khi cần theo dõi một thay đổi có nhiều bước hoặc migration.

## Cấu trúc

| Thư mục | Nội dung |
|---|---|
| [architecture](architecture/README.md) | Thiết kế tĩnh của hệ thống: client, server, dữ liệu, bảo mật và các integration. |
| [workflows](workflows/README.md) | Hành vi động: hành trình người dùng, đồng bộ, quy trình phát triển, CI và release. |
| [plans](plans/README.md) | Kế hoạch triển khai theo thời điểm: phạm vi, bước thực hiện và kiểm chứng của thay đổi nhiều phần. |

## Phạm vi hệ thống

OnlineTravelAgent là sản phẩm đặt và quản lý du lịch với:

- Flutter app cho khách hàng;
- Express/TypeScript API;
- PostgreSQL qua Prisma;
- Drift/SQLite cache ở thiết bị;
- Socket.IO cho cập nhật lịch trình;
- VNPay và MoMo ở ranh giới thanh toán;
- static Admin và Partner panels do backend phục vụ;
- GitHub Actions CI cho backend và Flutter.

## Quy ước source of truth

| Chủ đề | Nguồn sự thật |
|---|---|
| Hành vi giao diện và state | Mã trong lib và test. |
| API, authorization, transaction | Mã trong backend/src. |
| Schema và migration database | backend/prisma/schema.prisma và backend/prisma/migrations. |
| Runtime configuration | backend/src/core/config, backend/.env.example, README.md và CI. |
| Tài liệu kỹ thuật hiện hành | docs/architecture, docs/workflows và docs/plans. |

Tài liệu giải thích code, không thay thế code. Khi tài liệu và implementation mâu thuẫn, hãy coi code và test hiện tại là nguồn sự thật, sau đó cập nhật tài liệu trong cùng thay đổi.

## Quy tắc cập nhật tài liệu

| Khi thay đổi | Cập nhật tối thiểu |
|---|---|
| Route, middleware hoặc module backend | architecture/backend-and-api.md. |
| Schema, migration hoặc quan hệ dữ liệu | architecture/data-security-and-integrations.md. |
| Riverpod state, router, cache hoặc UI feature | architecture/mobile-client.md. |
| Hành trình booking, payment, admin hoặc partner | workflows/product-journeys.md. |
| Sync, offline cache hoặc Socket.IO event | workflows/sync-and-realtime.md. |
| Script, CI, môi trường hoặc deploy | workflows/development-and-quality.md hoặc workflows/operations-and-release.md. |
| Kế hoạch triển khai, migration hoặc thay đổi nhiều bước | plans/ với liên kết đến architecture/workflows liên quan. |

## Phạm vi không ghi nhận

Các file generated không được dùng làm tài liệu gốc: Drift generated files có hậu tố .g.dart, Prisma client generated files và output build. Chúng được sinh từ schema/source tương ứng.

## Tối ưu runtime đã triển khai

[Thiết kế tối ưu runtime và luồng dữ liệu](plans/2026-07-16-runtime-and-dataflow-optimization.md) mô tả các contract hiện tại cho persistent-data availability, cache bootstrap, snapshot Flutter, schedule batch và `TripStatus`. [Kế hoạch triển khai](plans/2026-07-16-runtime-and-dataflow-optimization-plan.md) lưu các bước và kiểm chứng đã thực hiện.

## Snapshot tài liệu

Tài liệu phản ánh source tree tại 2026-07-16: Flutter 3.44, Node.js 24, Express 5, Prisma 6/PostgreSQL, Riverpod, Drift và Socket.IO.
