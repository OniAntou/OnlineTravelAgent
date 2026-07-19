# Kiến trúc backend và API

## Runtime topology

Backend là ứng dụng Express/TypeScript chạy trên Node.js 24. Entry point là backend/src/server.ts; Express app được dựng ở backend/src/app.ts.

~~~mermaid
flowchart TD
    S["server.ts"] --> INIT["Initialize data availability"]
    S --> APP["Create Express app"]
    S --> IO["Attach Socket.IO"]
    APP --> MW["Security and transport middleware"]
    MW --> R["/api routes"]
    MW --> STATIC["/admin, /partner, /uploads"]
    R --> MOD["Feature modules"]
    MOD --> PRISMA["Prisma stores/services"]
    PRISMA --> PG[("PostgreSQL")]
    IO --> ROOMS["Trip/tour rooms"]
~~~

### Startup responsibilities

| File | Trách nhiệm |
|---|---|
| backend/src/server.ts | Khởi tạo data availability, HTTP server, Socket.IO và room authorization. |
| backend/src/app.ts | Cấu hình Express, middleware, static assets, health endpoint và error handler. |
| backend/src/modules/routes.ts | Mount client, payment, admin, partner, auth routers; rate limit module-level và cache invalidation. |
| backend/src/core/config/env.ts | Parse/validate runtime environment. |
| backend/src/core/config/data-availability.ts | Chọn persistent data hoặc error behavior khi database unavailable. |
| backend/src/core/config/cache.ts | Bootstrap cache và invalidation policy. |

## HTTP middleware và transport policy

Express app áp dụng các lớp sau theo thứ tự runtime:

| Lớp | Hành vi |
|---|---|
| Compression | Nén HTTP response. |
| Helmet | Security headers và CSP. |
| CORS | Chỉ chấp nhận origin được cấu hình. |
| JSON parser | Giới hạn JSON body ở 1 MB. |
| Static middleware | Phục vụ /admin, /partner và /uploads. |
| Global API limiter | 200 request trong 15 phút cho API. |
| Domain routers | Xác thực, validation và nghiệp vụ theo module. |
| Error handler | Chuẩn hóa lỗi thành response HTTP. |

Routes áp dụng thêm:

| Router scope | Chính sách |
|---|---|
| /api/auth | 20 request trong 15 phút, nhằm hạn chế login/register brute force. |
| Client router | 500 request trong 15 phút; mutation thành công invalidates bootstrap cache. |
| /api/admin | Basic Auth trước router. |
| /api/partner | JWT role PARTNER hoặc ADMIN trước router. |

## Module organization

~~~text
backend/src/
├── core/
│   ├── config/             env, cache, data availability
│   ├── middleware/         auth, validation, upload, panel protection
│   └── logging/            application logging
├── infrastructure/         database/memory adapters
├── modules/
│   ├── auth/               credentials, token lifecycle
│   ├── client/             mobile-facing aggregate API
│   ├── catalog/            stores for hotel, tour, search, review, promo
│   ├── booking/            idempotency support
│   ├── trips/              schedule service and realtime helpers
│   ├── payment/            VNPay, MoMo and callbacks
│   ├── admin/              protected admin CRUD
│   └── partner/            partner-scoped CRUD
├── app.ts
└── server.ts
~~~

Pattern chính là route → schema/middleware → controller/service/store → Prisma transaction/query. Controller không nên tự nhúng raw SQL hay bypass role/ownership checks.

## API mounting

Tất cả API được mount dưới /api.

| Prefix | Router | Auth |
|---|---|---|
| /api | clientRouter | Public hoặc client JWT theo endpoint. |
| /api/auth | authRouter | Public hoặc optional client JWT cho logout. |
| /api/payment | paymentRouter | Client JWT cho tạo/check; provider callback có signature verification. |
| /api/admin | adminRouter | Basic Auth. |
| /api/partner | partnerRouter | JWT role PARTNER/ADMIN. |

## Client API

Client routes nằm tại backend/src/modules/client/client.routes.ts.

| Nhóm | Method và path | Authorization | Mục đích |
|---|---|---|---|
| Bootstrap | GET /bootstrap | Optional auth | Trả catalog aggregate và phần user-scoped khi có session. |
| Search | GET /search | Public | Global search. |
| Favorite | GET /favorites; PATCH /destinations/:id/favorite | Client JWT | Đọc và cập nhật favorite cá nhân. |
| Promo | GET /promo-codes/check | Client JWT | Kiểm tra promo code. |
| Trips | GET /trips; GET /trips/schedules; GET /trips/:id/schedule | Client JWT | Đọc trip và schedule của owner. |
| Booking | POST /trips/book; POST /trips/book-flight; POST /hotels/book; POST /tours/book | Client JWT + Zod | Tạo trip từ service đã chọn. |
| Cancel | POST /trips/:id/cancel | Client JWT | Hủy trip của owner. |
| Flight | GET /flights/search | Public | Tìm flight. |
| Documents | GET/POST /documents; DELETE /documents/:id | Client JWT | Document của profile. |
| Hotels | GET /hotels; GET /hotels/search; GET /hotels/:id | Public | Catalog/detail hotel. |
| Tours | GET /tours; GET /tours/:id; GET /tours/:id/schedule | Public | Catalog/detail/template schedule tour. |
| Reviews | GET /reviews; POST /reviews; DELETE /reviews/:id | GET public; mutation client JWT | Review catalog. |

Controller client là backend/src/modules/client/client.controller.ts. Các stores thuộc backend/src/modules/catalog/data và logic booking/schedule dùng module booking/trips.

## Tour schedule seed

Catalog tour templates are normally read through `GET /api/tours/:id/schedule`.
To complete a database that is missing the five built-in catalog itineraries,
run `npm run db:seed:missing-tour-schedules` from `backend`. The command only
creates an absent template identified by the `sourceType: tour` and
`tourPackageId` pair, so it is safe to run again and never overwrites an
existing itinerary.

Do not use `npm run db:seed` for this maintenance operation: the general seed
deletes and recreates application data before it loads fixture data.

## Auth API

Routes ở backend/src/modules/auth/auth.routes.ts.

| Method | Path | Mục đích |
|---|---|---|
| POST | /api/auth/login | Kiểm tra password, phát token pair. |
| POST | /api/auth/register | Tạo user và token pair. |
| POST | /api/auth/refresh | Rotate refresh token, phát access token mới. |
| POST | /api/auth/logout | Revoke token/session hiện hành. |
| POST | /api/auth/become-partner | Đổi role của client theo flow nghiệp vụ hiện có. |

Auth module gồm auth.controller.ts, password.service.ts và token.service.ts. Password dùng bcrypt; service có đường migration cho password legacy SHA-256. Refresh token được lưu hash và rotate, không lưu token plaintext như dữ liệu business.

## Payment API

Routes ở backend/src/modules/payment/payment.routes.ts.

| Provider | Method và path | Vai trò |
|---|---|---|
| VNPay | POST /vnpay/create | Khởi tạo thanh toán cho trip của user. |
| VNPay | GET /vnpay/return | Xử lý browser return. |
| VNPay | POST /vnpay/ipn | Xử lý IPN và verify HMAC SHA-512. |
| VNPay | GET /vnpay/status/:tripId | Owner kiểm tra payment status. |
| MoMo | POST /momo/create | Khởi tạo request payment. |
| MoMo | GET /momo/return | Xử lý browser return. |
| MoMo | POST /momo/ipn | Xử lý IPN và verify HMAC SHA-256. |

Payment controller xác minh user sở hữu Trip và amount gửi lên khớp totalPrice ở server trước khi tạo request. Booking mới bắt đầu với `TripStatus.PENDING`; callback thanh toán đã xác thực chỉ chuyển trạng thái đó sang `ONGOING`. Nếu Admin đã hủy booking, callback vẫn ghi nhận payment result nhưng không kích hoạt lại chuyến đi.

## Admin API

Admin duy trì booking bằng Basic Auth. Dashboard trả thêm `tripsPending`; thẻ **Đơn chờ xác nhận** mở danh sách booking đã lọc `PENDING`. Admin có thể đặt booking về `PENDING`, `ONGOING`, `COMPLETED` hoặc `CANCELLED`; trạng thái pending và các trạng thái kết thúc luôn đồng bộ `isUpcoming` tương ứng.

`Destination.category` tham chiếu đến tên `Category` trong cơ sở dữ liệu. Màn hình quản trị chỉ cho chọn category hiện có, và backend kiểm tra giá trị này trước khi ghi dữ liệu. Nếu category không tồn tại, API trả về `400 Category not found` thay vì để lỗi ràng buộc dữ liệu trở thành thông báo chung.

Admin router ở backend/src/modules/admin/admin.routes.ts; trước router là Basic Auth.

| Nhóm | Khả năng |
|---|---|
| Upload | Nhận file upload hợp lệ. |
| Stats | Đọc dashboard aggregate. |
| Catalog | CRUD destination, hotel, room, flight, tour, category. |
| Trip | Liệt kê, cập nhật, xóa trip. |
| Schedule | Đọc/cập nhật/xóa per-trip schedule; CRUD schedule template. |
| User | Liệt kê, tạo và xóa user. |
| Partner | Liệt kê, tạo, sửa, cấp/thu hồi quyền và xóa Partner. Thu hồi/xóa Partner sẽ xóa hotel, room, tour thuộc sở hữu; dữ liệu database được xóa trước, sau đó mới dọn ảnh Supabase Storage. |
| Documents | CRUD document management. |

Controller admin dùng schedule service để bảo toàn quy tắc copy template/per-trip update và phát event realtime sau thay đổi liên quan.

## Partner API

Partner router ở backend/src/modules/partner/partner.routes.ts; middleware partnerAuth cho phép role PARTNER hoặc ADMIN.

| Nhóm | Path pattern | Ràng buộc |
|---|---|---|
| Upload | POST /api/partner/upload | JWT role hợp lệ. |
| Stats | GET /api/partner/stats | Dữ liệu scoped theo partnerId. |
| Hotel | GET/POST /hotels; PUT/DELETE /hotels/:id | Partner chỉ quản lý hotel của mình. |
| Tour | GET/POST /tours; PUT/DELETE /tours/:id | Partner chỉ quản lý tour của mình. |
| Room | GET/POST/PUT/DELETE dưới /hotels/:hotelId/rooms | Hotel và room phải thuộc partner. |

Static partner panel có thể chứa UI rộng hơn router thực tế. Capability chính thức được quyết định bởi partner routes/controllers, không bởi những nút xuất hiện trong HTML.

## Socket.IO

Socket initialization và room checks nằm tại backend/src/server.ts.

| Event | Server behavior |
|---|---|
| join_trip_room | Verify JWT, kiểm tra user ownership Trip, rồi join trip_{tripId}. |
| leave_trip_room | Rời trip room. |
| join_tour_room | Verify JWT, kiểm tra user có trip chưa hủy của tour, rồi join tour_{tourId}. |
| leave_tour_room | Rời tour room. |
| schedule_updated | Server phát khi schedule/template thay đổi; client refetch API. |

Không phát schedule payload như một database replica qua socket. Mục đích event là báo state đã đổi để client đọc state chuẩn qua protected API.

## Cache, database availability và error behavior

### Bootstrap cache

Each cached bootstrap response has an `ETag`. A client that sends the matching
`If-None-Match` receives `304 Not Modified`, avoiding a repeat aggregate JSON
transfer and local snapshot write. Cache and socket rooms are intentionally
single-instance for the project deployment model.

Catalogue migrations add GIN full-text and trigram indexes for every searched
name, location, description, and departure field while keeping the existing
Prisma full-text and case-insensitive substring query contract.

NodeCache giữ `bootstrapBase` và response `bootstrap_public`/`bootstrap_{userId}` với TTL 5 phút. Mutation catalogue hoặc review phải xóa toàn bộ nhóm bootstrap này, nhưng không xóa các key cache không liên quan. Favorite, booking, document và payment status chỉ xóa response bootstrap của user đã mutation.

Review read API dùng cursor (`cursor`, `limit` từ 1 đến 50; mặc định 20), aggregate count/rating ở PostgreSQL và `nextCursor`. Client chỉ tải trang kế tiếp khi người dùng yêu cầu.

### Database availability

`data-availability.ts` owns a short-lived, de-duplicated Prisma probe. Normal fallback decisions reuse that result instead of issuing `SELECT 1` in every store/action; `/health` explicitly forces a fresh probe.

Môi trường production không dùng memory mock như fallback khi PostgreSQL hỏng. Thay vào đó, data availability layer trả `PersistentDataUnavailableError` và HTTP 503. Điều này ưu tiên tính đúng dữ liệu hơn trả dữ liệu giả ở production.

### Error boundaries

Zod validation, auth errors, domain errors và persistence errors được map tại middleware error chung. Client cần hiển thị trạng thái lỗi/khôi phục; không nên giả định mọi failure là lỗi mạng.

## Static panels và uploads

| Path | Hành vi |
|---|---|
| /admin | Static admin panel. Bảo vệ static layer bằng Basic Auth khi REQUIRE_ADMIN_BASIC_AUTH=true; API luôn yêu cầu Basic Auth. |
| /partner | Static partner panel; API phía sau vẫn cần partner JWT. |
| /uploads | Phục vụ file upload theo UPLOAD_DIR. |

Upload middleware giới hạn kích thước 10 MB, kiểm MIME/extension cho image, PDF, DOC và DOCX, đồng thời dùng tên UUID để tránh collision/path injection trực tiếp.

## Backend test boundary

Tests nằm trong backend/tests và chạy bằng Vitest/Supertest. Mục tiêu là validation, auth, controller/service behavior và HTTP contract. CI hiện validate/build/test nhưng không chạy PostgreSQL service, migration against real database hay payment E2E provider callback.

## Source map

| Chủ đề | File khởi đầu |
|---|---|
| Server/Socket.IO | backend/src/server.ts |
| Express/middleware/static | backend/src/app.ts |
| API mounting/limit/cache invalidation | backend/src/modules/routes.ts |
| Auth | backend/src/modules/auth |
| Client aggregate API | backend/src/modules/client |
| Catalog/search/review/promo stores | backend/src/modules/catalog |
| Booking idempotency | backend/src/modules/booking/data/booking-idempotency.ts |
| Schedule | backend/src/modules/trips/schedule.service.ts |
| Payment | backend/src/modules/payment |
| Admin | backend/src/modules/admin |
| Partner | backend/src/modules/partner |
| Environment/security middleware | backend/src/core |
