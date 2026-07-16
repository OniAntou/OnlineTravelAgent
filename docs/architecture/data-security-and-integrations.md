# Dữ liệu, bảo mật và các integration

## PostgreSQL và Prisma

Database dùng PostgreSQL; Prisma schema nằm tại backend/prisma/schema.prisma. Prisma client là lớp truy cập chính của backend.

~~~mermaid
erDiagram
    USER ||--o{ TRIP : owns
    USER ||--o{ REFRESH_TOKEN : has
    USER ||--o{ DOCUMENT_ITEM : owns
    USER ||--o{ REVIEW : writes
    USER ||--o{ USER_FAVORITE_DESTINATION : saves
    HOTEL ||--o{ ROOM : contains
    HOTEL ||--o{ TRIP : booked_as
    TOUR_PACKAGE ||--o{ TRIP : booked_as
    DESTINATION ||--o{ TRIP : booked_as
    FLIGHT ||--o{ TRIP : booked_as
    TRIP ||--o{ TRIP_SCHEDULE_DAY : contains
    TRIP_SCHEDULE_DAY ||--o{ TRIP_SCHEDULE_ITEM : contains
    TOUR_PACKAGE ||--o{ SCHEDULE_TEMPLATE : defines
    DESTINATION ||--o{ SCHEDULE_TEMPLATE : defines
~~~

## Nhóm thực thể

| Nhóm | Models | Trách nhiệm |
|---|---|---|
| Identity | User, RefreshToken | Account, role và refresh session lifecycle. |
| Catalog | Category, Destination, Flight, Hotel, Room, TourPackage | Dữ liệu dịch vụ du lịch để browse/search/book. |
| User content | UserFavoriteDestination, DocumentItem, Review, PromoCode | Dữ liệu riêng hoặc nội dung gắn người dùng. |
| Booking | Trip | Giao dịch/đại diện hành trình của user. |
| Schedule template | ScheduleTemplate, ScheduleTemplateDay, ScheduleTemplateItem | Lịch chuẩn của tour/destination. |
| Trip schedule | TripScheduleDay, TripScheduleItem, TripScheduleUpdate | Lịch riêng được copy/override theo booking. |

## Enums và quyền

| Enum | Giá trị |
|---|---|
| Role | USER, PARTNER, ADMIN. |
| TripStatus | ONGOING, COMPLETED, CANCELLED. |
| PaymentStatus | PENDING, SUCCESS, FAILED. |
| ReviewTargetType | destination, hotel, tour, flight. |
| ScheduleSourceType | tour, destination. |

Role chỉ là một lớp authorization. Ownership checks vẫn cần thực hiện trên resource cụ thể: Trip thuộc user, Hotel/Tour thuộc partner và schedule thuộc trip tương ứng.

## Trip là transaction aggregate

Trip ghi:

- mô tả/lịch sử display như destination, location, date, guests, image path;
- source relation tùy loại booking: destinationId, tourPackageId, hotelId, roomId hoặc flightId;
- userId owner;
- totalPrice, promoCode, discount;
- requestId;
- payment method/status/transaction reference;
- schedule days và updates.

Trip không thay thế catalog entity. Nó lưu snapshot/quan hệ đủ để lịch sử booking vẫn đọc được khi catalog có thay đổi.

### Invariants đáng chú ý

| Invariant | Cách hiện thực |
|---|---|
| Không tạo trùng booking do retry | Unique constraint userId + requestId. |
| Trip liên kết source hợp lệ | Foreign-key/relation và validation/transaction trong booking flow. |
| User chỉ thấy trip của mình | userId filter và authorization ở client router. |
| Partner không sửa dữ liệu của partner khác | partnerId scope trong partner controller. |
| Payment không tin amount client | Server đối chiếu với totalPrice lưu trên Trip. |
| Data production không fallback giả | Persistent data unavailable trả lỗi 503. |

## Template và trip schedule

Schedule dùng hai cấp:

1. Template: schedule chuẩn gắn TourPackage hoặc Destination.
2. Per-trip schedule: schedule được copy khi user book, sau đó có thể được admin override/update riêng.

~~~mermaid
flowchart LR
    T["TourPackage or Destination"] --> ST["ScheduleTemplate"]
    ST --> SD["Template days/items"]
    B["Booking transaction"] --> COPY["Copy template"]
    COPY --> TD["TripScheduleDay"]
    TD --> TI["TripScheduleItem"]
    A["Admin update/override"] --> TU["TripScheduleUpdate"]
    TU --> TD
    TU --> EVENT["schedule_updated"]
~~~

Ưu điểm của thiết kế này là việc sửa template sau này không âm thầm làm thay lịch của chuyến người dùng đã đặt. Template updates và per-trip override có target riêng.

## Migration, seed và search

| Artifact | Mục đích |
|---|---|
| backend/prisma/migrations | Lịch sử thay đổi schema và data constraint. |
| backend/prisma/seed.ts | Seed dữ liệu development/demo. |
| backend/prisma/pg_trgm.sql | Extension/index PostgreSQL bổ sung để hỗ trợ search. |
| backend/prisma/schema.prisma | Declarative model, enum, relation/index. |

Workflow schema:

| Môi trường | Cách làm |
|---|---|
| Local development | Thay schema, chạy db:migrate:dev, generate client, seed khi cần. |
| CI hiện tại | Generate và validate schema; không có database service. |
| Production | Review migration, backup theo chính sách vận hành, chạy db:migrate trước/during deploy. |

Không sử dụng db push cho production vì nó không cung cấp migration history được review như deploy migration.

## Flutter local data model

Drift/SQLite là cache cục bộ, không phải database authority. Những table/DAO chính tại lib/data/local chứa:

- categories, destinations và favorites;
- hotels, rooms, flights, tour packages;
- documents, reviews, trips;
- trip schedule days/items/updates;
- offline queue legacy.

SyncService ghi snapshot theo transaction. Generated Drift files có hậu tố .g.dart và không chỉnh sửa thủ công.

## Authentication và token security

| Thành phần | Chính sách |
|---|---|
| Access token | JWT ngắn hạn 15 phút. |
| Refresh token | Tồn tại 30 ngày, được hash trong database, rotate/revoke qua auth service. |
| Mobile storage | flutter_secure_storage, không phải SQLite cache. |
| HTTP retry | Refresh single-flight, chỉ retry request gốc một lần. |
| Admin | Basic Auth với ADMIN_PASSWORD. |
| Partner | JWT role PARTNER hoặc ADMIN. |
| Socket room | JWT + resource ownership check trước khi join. |

Secrets được lấy từ environment; không đặt giá trị production trong source, seed hoặc Flutter binary.

## Runtime configuration

| Biến | Vai trò |
|---|---|
| DATABASE_URL | PostgreSQL connection string. |
| JWT_SECRET | Khóa ký/verify JWT. |
| ADMIN_PASSWORD | Basic Auth password cho admin API/panel protection. |
| CORS_ORIGINS | Danh sách web origin được phép. |
| TRUST_PROXY | Cấu hình proxy đúng với môi trường deploy. |
| SUPABASE_URL | URL project Supabase phục vụ Storage ảnh catalogue. |
| SUPABASE_SERVICE_ROLE_KEY | Khóa backend-only để ghi Storage; không được đưa vào client hay Git. |
| SUPABASE_STORAGE_BUCKET | Bucket ảnh, hiện là travel-media. |
| UPLOAD_DIR | Chỉ đọc tương thích các URL `/uploads/...` cũ. |
| REQUIRE_ADMIN_BASIC_AUTH | Bảo vệ static /admin panel bằng Basic Auth khi bật. |
| Payment provider variables | Khóa/callback config của VNPay và MoMo. |

Env parser yêu cầu các secret cần thiết ngoài test; production yêu cầu CORS_ORIGINS để không accidentally mở CORS.

## Payment integration

### VNPay

- Client yêu cầu tạo payment cho Trip đã tồn tại.
- Backend kiểm ownership và total amount.
- Backend tạo request signed.
- Return và IPN được verify HMAC SHA-512.
- PaymentStatus/transaction reference được cập nhật ở server.

### MoMo

- Backend tạo request cho Trip của owner.
- Return/IPN được xử lý ở backend.
- Callback dùng HMAC SHA-256.

Provider callback là authority cho kết quả digital payment. UI phải luôn map PaymentStatus server-side thay vì suy luận thành công chỉ từ điều hướng browser.

## Upload integration

Ảnh catalogue từ Admin/Partner đi qua endpoint upload đã có Basic Auth hoặc Partner JWT. Multer chỉ nhận một JPEG, PNG, GIF hoặc WebP tối đa 10 MB vào memory; backend dùng service-role key để ghi vào bucket public `travel-media` của Supabase Storage rồi trả `{ url }` với URL HTTPS tuyệt đối.

PostgreSQL chỉ lưu `imagePath` là URL; content nằm trong Storage nên mọi máy trỏ tới cùng backend/database đều xem cùng ảnh. Bucket public chỉ mở đọc qua URL, không cấp quyền upload/xóa cho anon hoặc authenticated. Service-role key chỉ có trong `backend/.env`; không đưa vào Flutter, HTML panels, log hoặc source control.

Asset bundled và giá trị `/uploads/...` cũ vẫn tương thích đọc; ảnh mới không ghi filesystem local.

Khi Admin hoặc Partner thay ảnh hay xóa catalogue record, backend giữ URL cũ, hoàn tất Prisma update/transaction trước, rồi xóa object cũ theo cơ chế best-effort. Chỉ URL public có đúng origin `SUPABASE_URL`, endpoint `/storage/v1/object/public/` và bucket cấu hình mới được xóa; asset bundled, `/uploads/...`, URL ngoài project và bucket khác luôn bị bỏ qua. Sự cố Storage chỉ được cảnh báo trong log, không rollback CRUD đã thành công. Upload rồi rời form trước khi record được lưu vẫn có thể tạo orphan; việc quét orphan định kỳ chưa thuộc phạm vi hiện tại.

## Security controls và operating boundaries

| Surface | Biện pháp hiện có |
|---|---|
| HTTP headers | Helmet/CSP. |
| Cross-origin | CORS whitelist. |
| Brute force | Global/general/auth rate limits. |
| Input | Zod schemas và JSON payload limit. |
| Authorization | JWT/Basic Auth/role/ownership middleware. |
| Realtime | Verify token và room ownership. |
| Upload | Type/size checks, key UUID không đoán được và server-only Storage credentials. |
| Database outage | 503 ở production thay vì memory data. |
| Cache privacy | Logout xóa user-owned cache. |

## Source map

| Chủ đề | File/thư mục |
|---|---|
| Prisma schema | backend/prisma/schema.prisma |
| Migrations | backend/prisma/migrations |
| Seed | backend/prisma/seed.ts |
| Search extension/index | backend/prisma/pg_trgm.sql |
| Auth middleware | backend/src/core/middleware/auth.ts |
| Upload middleware | backend/src/core/middleware/upload.ts |
| Supabase Storage service | backend/src/core/storage/supabase-storage.ts |
| Shared image handler | backend/src/core/http/image-upload-handler.ts |
| Env policy | backend/src/core/config/env.ts |
| Data availability | backend/src/core/config/data-availability.ts |
| Flutter database | lib/data/local/app_database.dart |
| Flutter auth/HTTP | lib/features/auth/application/auth_provider.dart và lib/data/remote/api_http_client.dart |
| Payment server | backend/src/modules/payment |
