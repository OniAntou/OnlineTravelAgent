# Workflows

Phần này mô tả hành vi động của OnlineTravelAgent: ai làm gì, hệ thống xử lý theo thứ tự nào và lệnh nào cần chạy ở từng giai đoạn.

| Tài liệu | Mục đích |
|---|---|
| [Hành trình nghiệp vụ](product-journeys.md) | Browse, auth, favorite, booking, payment, trip, admin và partner. |
| [Đồng bộ và realtime](sync-and-realtime.md) | Bootstrap cache, lifecycle, offline behavior, Socket.IO và schedule refresh. |
| [Phát triển và chất lượng](development-and-quality.md) | Dựng local, codegen, migration, test và CI. |
| [Vận hành và phát hành](operations-and-release.md) | Production configuration, release order, health check và vận hành an toàn. |

## Nguyên tắc đọc workflow

- Mỗi workflow phân biệt rõ client state/cache với server/database authority.
- Error path là một phần của workflow, không phải chi tiết phụ.
- Payment callback và schedule event chỉ hoàn tất sau khi server xác nhận/persist state.
- Lệnh backend phải chạy trong thư mục backend; lệnh Flutter chạy ở repository root.

## Optimization implementation

The runtime/data-flow optimization record and its [completed checklist](../plans/2026-07-16-runtime-and-dataflow-optimization-plan.md) live in [plans](../plans/2026-07-16-runtime-and-dataflow-optimization.md). Read them when changing cache, sync, schedule batching, or trip state.

## Cross-reference

| Cần hiểu | Đọc thêm |
|---|---|
| Router, provider, UI và cache implementation | ../architecture/mobile-client.md |
| HTTP route, middleware, Socket.IO server | ../architecture/backend-and-api.md |
| Prisma schema, auth, payment signatures | ../architecture/data-security-and-integrations.md |
