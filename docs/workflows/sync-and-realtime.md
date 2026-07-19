# Đồng bộ, cache offline và realtime

## Mục tiêu

Đồng bộ của dự án ưu tiên ba việc:

1. Hiển thị dữ liệu nhanh từ local cache.
2. Khôi phục dữ liệu mới khi API/mạng khả dụng.
3. Cập nhật lịch trình đúng sau event realtime mà không biến socket thành database thứ hai.

## Thành phần

| Thành phần | File chính | Vai trò |
|---|---|---|
| Bootstrap provider | Feature/application providers | Aggregate data cho UI từ cache và API. |
| SyncService | lib/data/services/sync_service.dart | Điều phối periodic/reconnect/foreground sync. |
| Drift database | lib/data/local/app_database.dart | Lưu snapshot cache theo transaction. |
| Connectivity service | lib/data/services/connectivity_service.dart | Báo connectivity change. |
| TravelApiService | lib/data/services/travel_api_service.dart | Facade API và Socket.IO lifecycle. |
| RealtimeRoomRegistry | lib/data/services/realtime_room_registry.dart | Lưu room cần rejoin. |
| Schedule providers | trip_schedule_provider.dart, tour_provider.dart | Join room và refetch schedule. |

## Bootstrap workflow

~~~mermaid
flowchart TD
    START["Bootstrap requested"] --> CACHE["Read SQLite snapshot"]
    CACHE --> PRIVATE{"Authenticated?"}
    PRIVATE -- "No" --> FILTER["Remove private/user-owned state"]
    PRIVATE -- "Yes" --> FETCH["Fetch /api/bootstrap"]
    FILTER --> FETCH
    FETCH --> OK{"API success?"}
    OK -- "Yes" --> WRITE["Replace snapshot transactionally"]
    WRITE --> STATE["Publish provider state"]
    OK -- "No, cache exists" --> STATE
    OK -- "No, empty cache" --> ERROR["BootstrapUnavailableException"]
~~~

### Dữ liệu trong snapshot

- categories;
- destinations và favorite projection;
- hotels, rooms, flights, tour packages;
- documents và reviews;
- trips;
- trip schedule days, items và updates.

### Privacy boundary

Cache có dữ liệu user-owned. Khi không có authenticated user, bootstrap phải lọc dữ liệu private; logout xóa dữ liệu private, favorite flag và offline queue legacy. Không bỏ bước này khi refactor cache vì nó ngăn user A nhìn thấy dữ liệu user B trên cùng thiết bị.

## Bootstrap persistence contract

Foreground bootstrap reads SQLite first, fetches `/api/bootstrap` once, returns that response to Riverpod, and passes the same `BootstrapData` to `SyncService.persistBootstrap`. `syncAll` remains the periodic/background entry point and fetches its own payload only when it actually runs.

Snapshot persistence removes only IDs absent from a successful payload, then upserts current rows in one transaction. Rooms are loaded in a single DAO query and grouped in memory during rehydration; the cache no longer wipes every catalogue table or issues one room query per hotel.

Trip schedule synchronization calls the client batch adapter after the snapshot transaction. The adapter sends at most 50 distinct IDs per request and merges the responses. A batch failure does not corrupt the already committed bootstrap snapshot.

## SyncService lifecycle

| Trigger | Hành động |
|---|---|
| App initialization | Khởi động periodic sync. |
| Mỗi 5 phút khi app active | Thử sync. |
| App foreground | Thử sync. |
| Connectivity reconnect | Thử sync. |
| App background | Dừng periodic timer. |

Guard hiện có:

- không cho hai sync chạy cùng lúc;
- giữ khoảng tối thiểu một phút giữa các sync;
- thay snapshot trong transaction;
- không biến cache failure thành crash nếu fallback còn dữ liệu.

## Offline semantics

| Loại hành vi | Hỗ trợ hiện tại |
|---|---|
| Đọc catalog/trips đã cache | Có, nếu snapshot tồn tại. |
| Mở app không mạng | Có nếu cache không rỗng. |
| Refresh server state | Chỉ khi API/network khả dụng. |
| Queue/replay booking mutation | Không phải contract được bảo đảm. |
| Queue/replay payment | Không nên làm; payment cần server/provider state rõ ràng. |

Offline queue table vẫn tồn tại trong Drift như legacy surface, nhưng implementation hiện tại clear/không replay mutation thay vì hứa hẹn eventual booking delivery.

## Realtime schedule workflow

~~~mermaid
sequenceDiagram
    participant Admin as Admin/Partner action
    participant API as Express schedule service
    participant DB as PostgreSQL
    participant Socket as Socket.IO
    participant App as Flutter provider

    Admin->>API: Update template or trip schedule
    API->>DB: Persist validated change
    DB-->>API: Commit
    API->>Socket: Emit schedule_updated to room
    Socket-->>App: schedule_updated
    App->>API: GET protected schedule endpoint
    API->>DB: Read current schedule
    DB-->>API: Current state
    API-->>App: Schedule payload
    App->>App: Re-render timeline
~~~

### Room contract

| Room | Join event | Server verification | Consumer |
|---|---|---|---|
| trip_{tripId} | join_trip_room | JWT hợp lệ và Trip thuộc user. | Trip schedule provider. |
| tour_{tourId} | join_tour_room | JWT hợp lệ và user có trip tour chưa hủy. | Tour schedule provider. |

Client cũng có leave_trip_room và leave_tour_room. RealtimeRoomRegistry giữ các room đang quan tâm để rejoin sau reconnect.

### Event contract

Event `schedule_updated` có nghĩa là schedule của target đã thay đổi. Nó không có nghĩa client đã có đủ state mới trong memory. Consumer chỉ invalidate/refetch khi payload chỉ đúng target đang theo dõi (`tripId` cho trip hoặc `tourId` cho tour), thay vì merge thủ công từ event chưa được xem như snapshot chính thức.

## Template-versus-trip state

| State | Owner | Thời điểm sử dụng |
|---|---|---|
| Schedule template | TourPackage hoặc Destination | Trước booking và để khởi tạo booking mới. |
| Trip schedule | Trip của user | Sau booking; timeline cụ thể cho hành trình đó. |
| Schedule update/override | Admin theo Trip | Khi cần thay đổi/ghi chú cho booking đã tạo. |

Template được copy để một sửa đổi catalog sau này không vô tình đổi lịch của chuyến đã đặt.

## Failure behavior

| Failure | Behavior |
|---|---|
| Socket cannot connect | App vẫn hoạt động với REST/cache; không tự suy luận schedule mới. |
| Socket reconnects | Registry rejoin rooms; event mới sẽ trigger refetch. |
| Refetch schedule fails | UI giữ state trước đó hoặc error state theo provider; không ghi state giả vào SQLite. |
| API unavailable | Sync fallback cache theo bootstrap contract. |
| Database unavailable in production | API trả 503; client không dùng memory fallback server-side. |

## Kiểm chứng khi thay đổi sync/realtime

1. Viết/điều chỉnh unit test cho SyncService guard và cache privacy.
2. Kiểm Provider test cho bootstrap success, cache fallback, empty-cache failure và logout cleanup.
3. Kiểm room authorization ở backend test: wrong user không join được trip/tour room.
4. Kiểm schedule service tạo/copy/update đúng rows.
5. Kiểm Flutter provider refetch khi schedule_updated.
6. Chạy flutter analyze, flutter test, backend build/test và Prisma validation.
