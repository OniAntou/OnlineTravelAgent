# Thiết kế tối ưu runtime và luồng dữ liệu

## Mục tiêu

Giảm round-trip không cần thiết, tránh xóa toàn bộ cache SQLite ở mỗi lần đồng bộ, giữ cache backend đúng phạm vi và dùng một trạng thái chuyến đi chuẩn xuyên API, SQLite, Riverpod và UI.

## Quyết định đã chốt

1. Một module data-availability sở hữu probe Prisma ngắn hạn, deduplicate probe đang chạy và quyết định khi nào non-production mới được dùng memory fallback. Health check buộc probe mới; request bình thường dùng kết quả TTL ngắn để không phát sinh `SELECT 1` cho từng thao tác.
2. Cache bootstrap backend chỉ xóa key `bootstrapBase`. Middleware invalidation chỉ gắn vào mutation làm thay đổi catalogue hoặc review aggregate; favorite, booking, document, payment và search cache không bị flush theo.
3. Bootstrap provider lấy payload một lần, sau đó chuyển chính payload đó cho `SyncService.persistBootstrap`. `syncAll` vẫn dành cho background refresh. Snapshot cache chỉ xóa row không còn trong payload, rồi upsert row hiện hữu; không còn wipe toàn bộ bảng catalogue/user snapshot.
4. Client chia danh sách trip ID theo contract tối đa 50 ID mỗi request. Server nhóm day/update bằng map một lượt thay cho lọc toàn bộ mảng cho từng trip.
5. `TripStatus` là enum chuẩn nội bộ. Adapter `fromServer` chuyển enum server/payment về enum client, adapter `fromStorage` đọc được cả giá trị canonical lẫn nhãn legacy. SQLite chỉ lưu storage value canonical; UI chỉ hiển thị label và kiểm tra enum.

## Luồng mới

~~~mermaid
sequenceDiagram
    participant P as Bootstrap provider
    participant API as Travel API
    participant S as SyncService
    participant DB as Drift/SQLite
    participant Schedule as Schedule API

    P->>DB: load cached snapshot
    P->>API: fetchBootstrap (một lần)
    API-->>P: BootstrapData
    P->>S: persistBootstrap(BootstrapData)
    S->>DB: remove stale IDs + upsert snapshot
    S->>Schedule: batch trip IDs (<= 50/request)
    Schedule-->>S: grouped schedules
    S->>DB: replace schedule rows per trip
    P-->>P: render fresh BootstrapData
~~~

## Ranh giới và lỗi

| Thành phần | Trách nhiệm | Hành vi lỗi |
|---|---|---|
| `data-availability.ts` | Probe/cache availability và policy fallback | Production ném `PersistentDataUnavailableError`; global error handler trả 503. |
| Cache middleware | Xóa đúng base bootstrap key sau mutation catalogue/review thành công | Không ảnh hưởng search cache hay user-owned state. |
| `SyncService` | Persist payload đã có, dọn stale row theo ID, tải schedule | Lỗi schedule chỉ được log; snapshot hợp lệ vẫn dùng được. |
| `TripApiService` | Chunk schedule request theo giới hạn server | Chunk lỗi làm request batch thất bại nguyên tử ở cấp caller. |
| `TripStatus` | Parse/serialize/display status | Giá trị legacy được normalize khi đọc cache; unknown không bị xem nhầm là ongoing. |

## Tương thích dữ liệu

Không đổi schema SQLite: cột `trips.status` tiếp tục là text. Giá trị mới gồm `pending_payment`, `upcoming`, `ongoing`, `completed`, `cancelled`, `unknown`. Khi đọc cache cũ, adapter chấp nhận `Upcoming`, `Ongoing`, nhãn tiếng Việt và raw enum server; lần sync kế tiếp sẽ ghi lại canonical value.

## Kiểm chứng

- Vitest: cache key scope, availability probe TTL/in-flight dedupe, group schedule batch.
- Flutter test: bootstrap chỉ fetch một lần, stale cache row bị bỏ nhưng snapshot không wipe, room hydrate bằng một query, status legacy/canonical và filter provider.
- Regression suite: `npm run build`, `npm test`, `flutter analyze`, `flutter test`.
