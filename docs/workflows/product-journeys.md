# Hành trình nghiệp vụ

Tài liệu này mô tả flow đang được code hiện tại thực thi. Các API path đều bắt đầu bằng /api trừ khi ghi rõ khác.

## 1. Mở ứng dụng và tải dashboard

~~~mermaid
sequenceDiagram
    participant U as User
    participant F as Flutter
    participant C as SQLite cache
    participant A as Express API
    participant D as PostgreSQL

    U->>F: Open app
    F->>F: Show Welcome route
    F->>C: Read cached bootstrap snapshot
    F->>A: GET /bootstrap
    A->>D: Read catalog and user-scoped data
    D-->>A: Fresh data
    A-->>F: Bootstrap payload
    F->>C: Replace snapshot transactionally
    F-->>U: Render MainScreen tabs
~~~

| Điều kiện | Hành vi |
|---|---|
| API thành công | UI dùng payload mới và cache được thay. |
| API lỗi, cache có dữ liệu | UI dùng cache đã có. |
| API lỗi, cache rỗng | UI hiện bootstrap unavailable/error state. |
| App foreground hoặc network reconnect | SyncService yêu cầu sync mới theo guard/rate limit. |

Welcome là entry route ở mỗi launch. MainScreen chứa Dashboard, My Trips, Favorites và Profile bằng lazy IndexedStack.

## 2. Đăng ký, đăng nhập và phiên

~~~mermaid
sequenceDiagram
    participant F as Flutter
    participant A as Auth API
    participant D as PostgreSQL
    participant S as Secure Storage

    F->>A: POST /auth/register or /auth/login
    A->>D: Validate credentials and user
    D-->>A: User/refresh token record
    A-->>F: Access token and refresh token
    F->>S: Persist token pair and profile
    F->>A: Protected request with Bearer token
    A-->>F: Protected response
    F->>A: POST /auth/refresh only after 401
    A-->>F: Rotated token pair
~~~

### Luồng chi tiết

1. User mở Login hoặc Register screen.
2. AuthNotifier gọi AuthApiService.
3. Backend validate payload bằng Zod, kiểm password hoặc tạo user mới.
4. Backend phát JWT access token và refresh token.
5. Flutter lưu token/profile trong flutter_secure_storage.
6. ApiHttpClient gắn access token vào request tiếp theo.
7. Nếu nhận 401, HTTP client bắt đầu một refresh dùng chung; các request đồng thời chờ cùng Future.
8. Chỉ retry request gốc một lần. Nếu refresh thất bại, client logout và xóa dữ liệu private.

| API | Mục đích |
|---|---|
| POST /auth/login | Đăng nhập. |
| POST /auth/register | Tạo account. |
| POST /auth/refresh | Rotate refresh token/lấy access token mới. |
| POST /auth/logout | Revoke session/refresh token. |
| POST /auth/become-partner | Thay đổi role theo flow partner hiện có. |

## 3. Khám phá catalog, search và favorite

### Browse và search

1. Dashboard/feature provider nhận catalog từ bootstrap.
2. User có thể mở destination, hotel, flight hoặc tour detail.
3. Search dùng GET /search, GET /hotels/search hoặc GET /flights/search tùy bề mặt.
4. Detail có thể gọi endpoint chi tiết nếu dữ liệu bootstrap chưa đủ.

Các catalog endpoint public gồm hotels, tours, flight search và general search; API vẫn là source of truth cho dữ liệu mới hơn cache.

### Favorite

1. User nhấn favorite trên destination.
2. Provider cập nhật UI optimistic.
3. Client gọi PATCH /destinations/:id/favorite cùng Bearer token.
4. Backend cập nhật UserFavoriteDestination của user đó.
5. Nếu request lỗi, provider phải rollback/hiển thị lỗi theo state handling.
6. Bootstrap lần sau trả favorite state user-scoped.

Mutation cho cùng destination được serialize để tránh trạng thái UI đảo lộn do nhiều tap nhanh.

## 4. Đặt dịch vụ

Booking bắt đầu từ các detail/checkout surface. Guest được yêu cầu đăng nhập trước khi action tạo Trip.

~~~mermaid
flowchart TD
    SELECT["Chọn destination, tour, hotel/room hoặc flight"] --> AUTH{"Đã đăng nhập?"}
    AUTH -- "No" --> LOGIN["Đi tới login"]
    AUTH -- "Yes" --> ID["Tạo requestId UUID"]
    ID --> REQUEST["Gọi booking endpoint"]
    REQUEST --> VALIDATE["Server validate source, user và payload"]
    VALIDATE --> TX["Tạo hoặc trả lại Trip idempotent"]
    TX --> SCHEDULE{"Destination hoặc tour?"}
    SCHEDULE -- "Yes" --> COPY["Copy template thành per-trip schedule"]
    SCHEDULE -- "No" --> PAYMENT["Chuyển flow payment/success"]
    COPY --> PAYMENT
~~~

### Booking endpoint matrix

| Service | Endpoint | Kết quả |
|---|---|---|
| Destination/custom trip | POST /trips/book | Tạo Trip và có thể copy destination schedule. |
| Flight | POST /trips/book-flight | Tạo Trip liên kết flight. |
| Hotel/room | POST /hotels/book | Tạo Trip liên kết hotel/room. |
| Tour | POST /tours/book | Tạo Trip và copy tour schedule template. |

### Quy tắc server-side

- Client sinh requestId; database có unique userId + requestId để retry không tạo trip trùng.
- Backend kiểm source và dữ liệu booking trong transaction.
- Trip lưu owner, source relation, total price, promo/discount và payment state. Booking mới có `TripStatus.PENDING`; callback thanh toán hợp lệ chuyển pending sang `ONGOING`, nhưng không được kích hoạt lại booking mà Admin đã hủy.
- Destination/tour dùng template-to-trip copy; hotel/flight không sinh cùng loại schedule copy.
- User chỉ có thể đọc/cancel Trip của chính mình.

## 5. Checkout và payment

Payment luôn bắt đầu với Trip đã được tạo, không để provider callback tự tạo booking.

### Hợp đồng payment

| Thành phần | Trách nhiệm |
|---|---|
| Flutter payment screens | Chọn phương thức, hiển thị redirect/status/error. |
| Payment API | Xác minh Trip owner và amount; tạo provider request; xử lý callback. |
| Provider | Xác thực/payment processing và gửi return/IPN. |
| PostgreSQL Trip | Lưu payment method, PaymentStatus và transaction references. |

### VNPay

1. Flutter yêu cầu POST /payment/vnpay/create cho Trip của user.
2. Backend đối chiếu amount client với totalPrice của Trip.
3. Backend tạo request đã ký và trả URL/provider information.
4. User hoàn tất ở VNPay.
5. VNPay gọi return và IPN.
6. Backend kiểm HMAC SHA-512, cập nhật PaymentStatus và transaction reference.
7. Flutter kiểm GET /payment/vnpay/status/:tripId hoặc reload trip để hiển thị kết quả.

### MoMo

Backend có POST /payment/momo/create, GET /payment/momo/return và POST /payment/momo/ipn. Mobile payment menu hiện tại không nên được coi là đã expose hoàn chỉnh luồng MoMo chỉ vì backend integration tồn tại; trước khi hiển thị cho user, cần có caller/UI mapping và test callback hoàn chỉnh.

### Payment status contract

Server enum là PENDING, SUCCESS hoặc FAILED. Client code phải map contract này một cách thống nhất; không nên thêm điều kiện string riêng như PAID mà không có mapper/API contract tương ứng.

## 6. My Trips và lịch trình

1. User mở My Trips trong MainScreen.
2. Trips provider đọc bootstrap/API data scoped theo owner.
3. UI nhóm upcoming/ongoing/history dựa trên trip state và date logic.
4. User mở detail tour/destination.
5. Trip schedule provider gọi GET /trips/:id/schedule.
6. Provider join room trip tương ứng để nhận schedule_updated.
7. Khi event đến, provider refetch protected API để render state mới.
8. User có thể cancel qua POST /trips/:id/cancel nếu điều kiện nghiệp vụ cho phép.

Schedule detail UI không tự tin socket payload là toàn bộ timeline. Socket chỉ báo rằng cần tải lại dữ liệu từ server.

## 7. Admin quản trị dữ liệu

1. Admin mở static panel ở /admin.
2. Khi static panel protection bật, server yêu cầu Basic Auth ngay ở static layer.
3. Panel gọi /api/admin với Basic credentials.
4. Admin CRUD catalog, trip, user, document, schedule template hoặc per-trip schedule.
5. Admin có thể tạo Partner trực tiếp hoặc cấp quyền Partner cho User. Khi thu hồi quyền hoặc xóa Partner, hệ thống yêu cầu xác nhận và xóa toàn bộ hotel, room, tour mà Partner sở hữu.
5. Backend validate input, persist thay đổi và phát schedule_updated khi schedule liên quan thay đổi.
6. Client đang ở room liên quan refetch lịch trình.

Admin API luôn được Basic Auth ngay cả khi static panel protection chưa bật.

## 8. Partner quản lý cung cấp

1. Partner đăng nhập lấy JWT có role PARTNER hoặc ADMIN.
2. Partner panel gọi /api/partner.
3. partnerAuth kiểm role.
4. Controller lấy partnerId từ JWT.
5. Partner CRUD hotel, tour, room và đọc stats trong scope của chính mình.
6. Server từ chối record không thuộc partner dù UI có cố gọi URL thủ công.

## 9. Documents và reviews

### Documents

User dùng Profile để gọi:

- GET /documents để xem dữ liệu của mình;
- POST /documents để tạo;
- DELETE /documents/:id để xóa.

Backend filter theo userId, và logout client xóa cached user-owned documents.

### Reviews

Reviews được đọc public qua GET /reviews. Việc tạo/xóa yêu cầu client JWT và target type hợp lệ. Review data có thể được aggregate vào bootstrap/catalog projection.

## 10. Failure và offline behavior

| Scenario | Hành vi mong đợi từ implementation hiện tại |
|---|---|
| API unavailable lúc launch, cache có | Read-only cached experience. |
| API unavailable lúc launch, cache rỗng | Bootstrap unavailable/error state. |
| Network mất sau khi đã tải | UI vẫn có snapshot trước đó; mutation báo lỗi theo API policy. |
| Token hết hạn | HTTP client refresh single-flight; logout nếu không thể refresh. |
| Database production unavailable | Backend trả 503 PersistentDataUnavailableError thay vì dữ liệu mock. |
| Socket disconnect | Room registry rejoin sau reconnect; provider refetch khi có event tiếp theo. |
| Booking retry | requestId giúp server tránh duplicate transaction. |

Offline queue legacy không phải guarantee cho booking replay. Không mô tả workflow này như hỗ trợ thanh toán/đặt dịch vụ offline.
