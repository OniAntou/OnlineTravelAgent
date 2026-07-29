# Kiến trúc Flutter mobile client

## Stack và vai trò

| Công nghệ | Vai trò |
|---|---|
| Flutter 3.44 / Dart | Presentation và platform application. |
| flutter_riverpod | Application state và feature state. |
| go_router | Entry routes cấp ứng dụng. |
| http | REST transport qua ApiHttpClient. |
| flutter_secure_storage | Access/refresh token và profile cục bộ. |
| Drift + SQLite | Snapshot cache và bảng offline/local. |
| socket_io_client | Realtime schedule signal. |
| connectivity_plus | Trigger đồng bộ khi mạng quay lại. |
| easy_localization | Tiếng Việt mặc định, tiếng Anh là locale hỗ trợ. |
| flutter_map | Hiển thị bản đồ. |
| geolocator | Lấy vị trí thiết bị khi người dùng mở chi tiết chuyến đi. |

## Khởi động và lifecycle

Entry point là lib/main.dart.

~~~mermaid
sequenceDiagram
    participant OS as Operating system
    participant Main as lib/main.dart
    participant Scope as Riverpod ProviderScope
    participant State as App state
    participant Sync as SyncService
    participant UI as Router/MainScreen

    OS->>Main: launch
    Main->>Main: initialize binding, localization, error handlers
    Main->>Scope: create provider container
    Scope->>State: initialize app state
    State->>Sync: start periodic sync
    State->>UI: render routed application
    OS->>State: foreground or connectivity restored
    State->>Sync: syncAll
    OS->>State: background
    State->>Sync: stop periodic timer
~~~

App state ở lib/app/state/app_state_provider.dart điều phối SyncService:

- khởi động periodic sync 5 phút;
- sync khi app trở lại foreground;
- sync khi connectivity reconnect;
- tránh sync đồng thời và dừng timer khi app background.

Đây không phải background task được hệ điều hành bảo đảm chạy khi app đã bị kill.

### GPS trong chi tiết chuyến đi

GPS chỉ được khởi động từ màn hình chi tiết chuyến đi khi lịch trình còn một
điểm có tọa độ. Subscription dừng khi màn hình bị dispose hoặc ứng dụng không
còn foreground; ứng dụng không yêu cầu background location, không geofence và
không ghi lịch sử hành trình. Tọa độ thô chỉ tồn tại trong bộ nhớ để hiển thị
marker hiện tại, tính khoảng cách tới điểm kế tiếp và mở ứng dụng bản đồ của
thiết bị. Request duy nhất tới backend là xác nhận thủ công `completed` cho
schedule item thuộc chính chuyến đi của người dùng, không gửi tọa độ.

## Source layout

| Khu vực | Trách nhiệm |
|---|---|
| lib/app | App lifecycle, shell và app-level state. |
| lib/core | Router, constants, theme và utilities dùng toàn app. |
| lib/data/remote | HTTP client và API services theo domain. |
| lib/data/local | Drift database, tables, DAOs và generated code. |
| lib/data/services | API facade/provider, connectivity, sync, realtime room registry. |
| lib/features | Domain/application/presentation theo use case. |
| lib/screens | Màn hình composition hoặc surface dùng chung còn tồn tại trong dự án. |
| lib/shared | Widget/hàm dùng chung. |
| assets/images | Ảnh dùng bởi app. |
| assets/translations | Tài nguyên đa ngôn ngữ. |

Feature directories hiện có gồm auth, booking, dashboard, destinations, favorites, flights, food, hotels, notifications, partner, profile, search, tours, trips và welcome.

## Router và navigation

Router được định nghĩa tại lib/core/router/app_router.dart, route constants tại lib/core/router/app_routes.dart.

| Route | Surface | Điều kiện |
|---|---|---|
| / | Welcome screen | Entry route cố định cho mỗi lần launch. |
| /main | Main shell và các tabs | Public. |
| /login | Đăng nhập | Public. |
| /register | Đăng ký | Public. |
| /partner-dashboard | Partner dashboard | Redirect về login khi chưa xác thực. |

Router sử dụng initialLocation bằng Welcome và overridePlatformDefaultLocation bằng true. Điều này chủ động ưu tiên Welcome screen hơn platform-restored path ở mỗi lần mở app.

MainScreen ở lib/app/shell/main_screen.dart dùng lazy IndexedStack để giữ state giữa Dashboard, My Trips, Favorites và Profile. Những luồng có state ngắn hạn như checkout vẫn dùng Navigator/callback ở một số vị trí; không nên xem đây là lỗi trừ khi một thay đổi cụ thể yêu cầu deep link/back-stack khác.

## State và data flow

~~~mermaid
flowchart TD
    API["TravelApiService / remote APIs"] --> BP["Bootstrap provider"]
    DB["Drift SQLite"] --> BP
    BP --> FP["Feature providers"]
    FP --> UI["Flutter screens/widgets"]
    UI --> FP
    FP --> API
    API --> HTTP["ApiHttpClient"]
    HTTP --> SERVER["Express API"]
~~~

### Bootstrap provider

Bootstrap là aggregate dữ liệu khởi tạo UI:

1. Đọc full snapshot từ SQLite.
2. Nếu không đăng nhập, bỏ dữ liệu private/user-owned khỏi snapshot cục bộ.
3. Gọi GET /api/bootstrap.
4. Cập nhật providers và thay cache snapshot trong transaction khi request thành công.
5. Fallback sang cache nếu API lỗi nhưng cache không rỗng.
6. Báo BootstrapUnavailableException khi cả API lẫn cache không khả dụng.

### Feature providers

Các provider theo feature nhận dữ liệu từ bootstrap/API, đóng gói mutation UI và chuyển state sang màn hình. Ví dụ:

| Provider/domain | Hành vi đáng chú ý |
|---|---|
| Auth | Restore session, login/register/logout, cập nhật profile. |
| Destination/Favorite | Toggle favorite optimistic và serialize mutation theo destination. |
| Trips | Tạo booking, nhóm dữ liệu theo state/dates; hiển thị kết quả đổi lịch/hoàn tiền sau khi Admin xét duyệt. |
| Trip change request | Tải theo Trip owner-scoped, gửi đổi lịch hoặc hoàn tiền; disable action khi còn `PENDING`. |
| Trip schedule | Join trip room và refetch khi có schedule_updated. |
| Tour | Tải tour, lịch template và join tour room khi cần. |
| Profile/Documents | Đọc/tạo/xóa document thuộc user. |

## Networking và session

### ApiHttpClient

File lib/data/remote/api_http_client.dart là lớp HTTP chung. Nó:

- gắn access token vào request cần auth;
- nhận 401 và điều phối refresh token;
- dùng một Future refresh dùng chung để không tạo refresh storm;
- sở hữu một `http.Client` dùng lại cho mọi adapter HTTP và đóng nó cùng lifecycle `TravelApiService`;
- chỉ retry request gốc một lần;
- chuyển lỗi HTTP thành ApiException/taxonomy UI có thể xử lý.

### API services

Các services dưới lib/data/remote phân chia theo domain:

| Service | Domain |
|---|---|
| auth_api_service.dart | Login, register, refresh, logout, become partner. |
| location_api_service.dart | Destination, hotel, flight, tour, search, favorite, promo. |
| trip_api_service.dart | Trips, booking, change request, schedule. |
| payment_api_service.dart | Tạo/kiểm tra luồng payment. |
| document_api_service.dart | Documents của profile. |
| review_api_service.dart | Review. |
| partner_api_service.dart | Partner dashboard/API. |

TravelApiService tại lib/data/services/travel_api_service.dart là facade cho callers cũ/mới và giữ lifecycle Socket.IO. api_provider.dart cung cấp service cho Riverpod.

### Secure storage

Auth state lưu access token, refresh token, name, email và role trong flutter_secure_storage. Token không được coi là session authority cuối cùng: server vẫn verify JWT và ownership cho mọi protected action.

## Local persistence, offline và sync

### Bootstrap, snapshot và TripStatus

`bootstrapProvider` đọc SQLite trước, fetch `/api/bootstrap` đúng một lần, trả payload mới cho UI và chuyển cùng payload đó vào `SyncService.persistBootstrap`. `syncAll` chỉ là entry point của periodic/background refresh nên không lặp lại request foreground.

Snapshot transaction xóa row đã vắng mặt theo ID rồi upsert dữ liệu hiện tại; không wipe toàn bộ catalogue. Rehydration lấy toàn bộ room một lần rồi group theo hotel ID. Schedule adapter chia tối đa 50 trip ID/request để khớp contract backend. Sau lần fetch đầu, periodic sync dùng ETag/If-None-Match; `304 Not Modified` bỏ qua cả payload lẫn transaction SQLite.

`TripStatus` là enum chuẩn giữa JSON adapter, Drift text storage, provider và widget. Cột SQLite vẫn là text, nhưng ghi canonical value (`pending_payment`, `upcoming`, `ongoing`, `completed`, `cancelled`, `unknown`) và parser vẫn đọc được nhãn legacy để cache cũ không bị vỡ. Trạng thái kết thúc (`completed`, `cancelled`) luôn được ưu tiên hơn `PaymentStatus.PENDING` legacy, nên lịch sử thanh toán không thể đưa booking đã kết thúc trở lại danh sách sắp tới.

Drift database được định nghĩa tại lib/data/local/app_database.dart, tables và DAOs nằm trong lib/data/local/tables và lib/data/local/daos.

Snapshot cache chứa catalog, favorites, hotels, rooms, flights, tours, documents, trips và trip schedules. Cache được thay bởi transaction, thay vì từng widget tự ghi bảng riêng.
Yêu cầu đổi lịch/hoàn tiền được đọc trực tiếp theo Trip qua `tripChangeRequestsProvider`; không ghi vào Drift hoặc offline queue vì đây là mutation cần trạng thái server mới nhất.

| Tình huống | Hành vi hiện tại |
|---|---|
| Có mạng/API thành công | Lấy bootstrap mới, ghi cache, UI dùng state mới. |
| API lỗi nhưng cache có | Hiển thị cache đã có. |
| API lỗi và cache rỗng | Hiển thị trạng thái bootstrap unavailable. |
| Logout | Xóa dữ liệu private, favorite flag và legacy offline queue. |
| Mutation khi offline | Không có replay booking đáng tin cậy; mutation mặc định không queue khi lỗi. |

Offline-first ở dự án hiện có nghĩa là cache-first cho đọc, không phải đặt dịch vụ offline rồi tự gửi lại an toàn.

## Socket.IO và schedule

RealtimeRoomRegistry tại lib/data/services/realtime_room_registry.dart ghi nhận các room client đang theo dõi.

| Room | Điều kiện join do server xác thực | Consumer |
|---|---|---|
| trip_{tripId} | User là owner của Trip. | Trip schedule provider. |
| tour_{tourId} | User có trip chưa hủy liên quan tour. | Tour provider/schedule. |

Client rejoin rooms sau reconnect. Khi nhận `schedule_updated`, trip provider chỉ invalidate khi payload có đúng `tripId`, còn tour provider chỉ invalidate khi payload có đúng `tourId`; event của room khác hoặc payload rỗng bị bỏ qua. Event không mang toàn bộ state authoritative.

## UI module map

| Module | Các surface chính |
|---|---|
| welcome | Welcome/entry screen. |
| auth | Login, register và restore session. |
| dashboard/search/destinations | Khám phá catalog, tìm kiếm và destination. |
| hotels/flights/tours | Duyệt detail và chọn dịch vụ. |
| booking | Checkout, VNPAY và tiền mặt làm cổng payment test ở local/test; Flutter release chỉ hiện cash với `--dart-define=ALLOW_TEST_PAYMENTS=true`; chuyển khoản/card trực tiếp bị ẩn đến khi có đối soát server-side. |
| trips | My Trips, detail destination/tour, timeline lịch trình, gửi và xem trạng thái đổi lịch/hoàn tiền. |
| favorites | Danh sách destination đã lưu. |
| profile | Profile và documents. |
| partner | Partner dashboard. |
| notifications/food | Các feature presentation hỗ trợ hiện có. |

## Generated code và code generation

Drift tạo các file .g.dart từ app database, tables và DAOs. Khi thay schema/table/DAO:

~~~powershell
dart run build_runner build --delete-conflicting-outputs
~~~

Không chỉnh sửa trực tiếp generated files.

## Test surfaces

Test Flutter ở test/ được nhóm theo app, core, data, features, helpers và shared. Khi sửa layer:

| Layer sửa | Kiểm chứng tối thiểu |
|---|---|
| Router/app lifecycle | Router/provider tests và flutter test. |
| API client/auth | Unit tests cho refresh/retry và flutter test. |
| Drift/sync | DAO/sync tests và flutter test. |
| UI/feature | Widget/unit test liên quan, flutter analyze, flutter test. |
