# Review kế hoạch refactor

**Ngày:** 2026-07-15
**Trạng thái:** Không triển khai kế hoạch refactor hiện tại nguyên bản. Hãy thay bằng kế hoạch theo phạm vi dưới đây.

## Kết luận ngắn

Bản review đã nhận diện được vài khu vực đáng cải thiện: `tour_detail_screen.dart` còn lớn, routing đang pha trộn giữa GoRouter và Navigator, và bootstrap/offline sync là một seam phức tạp. Tuy nhiên, bản kế hoạch hiện tại quá rộng, thiếu bằng chứng và không phù hợp để triển khai trực tiếp.

Không được dùng ngôn ngữ xúc phạm, tình dục hoặc nhận định cảm tính trong tài liệu kỹ thuật. Mọi phát hiện phải nêu file, hành vi hiện tại, tác động, phương án thay đổi và cách kiểm chứng.

## Bằng chứng từ code hiện tại

### 1. `TravelApiService` không nên bị xóa ngay

`lib/services/travel_api_service.dart` đang là façade cho các service đã được tách ở `lib/services/api/` (`AuthApiService`, `TripApiService`, `LocationApiService`, v.v.). Nó vẫn có thể được làm mỏng hơn, nhưng xóa ngay sẽ phá vỡ nhiều caller và test hiện hữu:

- 25 file đang dùng `apiProvider`.
- 11 file/test phụ thuộc trực tiếp vào `TravelApiService`.
- `ApiHttpClient` đang tập trung token, refresh-token single-flight, retry và chính sách release URL.

**Yêu cầu:** nếu cần tách provider theo domain, thực hiện dần sau một interface tương thích; không dùng bước `[DELETE] travel_api_service.dart` trong đợt đầu.

### 2. Nhận định về Socket.IO đã lỗi thời

Socket hiện được cache trong getter; các room được theo dõi bằng `RealtimeRoomRegistry` và tự rejoin sau kết nối lại:

- `lib/services/travel_api_service.dart:86-153`
- `lib/services/realtime_room_registry.dart`
- `test/services/realtime_room_registry_test.dart`

Test registry realtime hiện pass 2/2. Chỉ tách `SocketService` khi có một mục tiêu cụ thể về lifecycle, observability hoặc ownership; khi đó phải giữ nguyên contract `joinTripRoom`, `leaveTripRoom`, `joinTourRoom`, `leaveTourRoom` và bổ sung test lifecycle.

### 3. Repository cho bootstrap là ứng viên tốt, nhưng cần giữ nguyên hành vi

`bootstrapProvider` hiện đảm nhận:

- đọc cache SQLite trước;
- loại dữ liệu thuộc người dùng khi chưa đăng nhập;
- fetch dữ liệu mới;
- fallback sang cache khi API lỗi;
- đồng bộ lại SQLite.

Đây là một seam hợp lý cho `BootstrapRepository`. Tuy nhiên, repository phải đóng gói toàn bộ các quy tắc trên, không chỉ di chuyển lệnh gọi API.

Có một vấn đề cụ thể nên ưu tiên: `bootstrapProvider` gọi `api.fetchBootstrap()` rồi gọi `syncAll()`, trong khi `SyncService.syncAll()` lại gọi `api.fetchBootstrap()` lần nữa. Thiết kế mới cần viết cache từ payload vừa fetch để tránh double-fetch.

### 4. Không chuyển toàn bộ `Navigator.push` sang GoRouter bằng tìm-thay thế

Routing hiện đúng là pha trộn. Nhưng `MainScreen` đang quản lý tab nội bộ và destination được chọn qua Riverpod; luồng checkout còn truyền callback. Việc "xóa sạch Navigator" sẽ thay đổi back stack và state ownership, không chỉ đổi cú pháp.

**Yêu cầu:** trước khi migrate, thiết kế route contract cho từng flow:

- path/name, path parameters và `extra`;
- điều kiện auth và redirect;
- back behavior;
- deep-link có hỗ trợ hay không;
- phần nào vẫn là transient route/modal và hợp lý khi giữ Navigator.

Ưu tiên migrate các route độc lập, deep-linkable trước. Không migrate checkout callback và tab state trong cùng đợt.

### 5. UI refactor phải dựa trên trách nhiệm và profiling

`tour_detail_screen.dart` là ứng viên tốt để tách section. Tuy nhiên, date, guest count và giá hiện là local UI state; đưa chúng vào `Notifier` chỉ hợp lý nếu state được chia sẻ, có validation phức tạp hoặc phải sống qua route.

`dashboard_screen.dart` đã dùng nhiều widget con và các `ListView` ngang. Chuyển sang sliver chỉ khi Flutter DevTools/profile chứng minh có jank hoặc chi phí layout đáng kể; đây không phải tối ưu bắt buộc chỉ vì file có `SingleChildScrollView`.

### 6. Sync hiện không phải background sync vô kiểm soát

`SyncService` có timer 5 phút, guard chống sync trùng và dừng timer khi app pause. `test/services/sync_service_test.dart` hiện pass 16/16.

Không thêm WorkManager chỉ vì có SQLite. Nếu sản phẩm thực sự cần sync nền, hãy ghi rõ yêu cầu, dữ liệu được đồng bộ, tần suất, giới hạn pin/dữ liệu di động và khác biệt Android/iOS trước khi chọn giải pháp.

### 7. Chưa quyết định dùng `fpdart` hoặc `multiple_result`

Codebase đã có `ApiException`, `AuthException`, `ValidationException`, `NetworkException` và các lỗi có kiểu khác tại `lib/utils/api_exception.dart`.

Trước tiên cần thống nhất error taxonomy và cách UI map lỗi sang trạng thái hiển thị. Chỉ đưa `Result` type vào nếu có use case cụ thể chứng minh exception hiện tại gây lỗi xử lý; không thực hiện migration toàn app trong đợt refactor này.

## Kế hoạch thay thế bắt buộc

### Giai đoạn 0 — Bảo vệ worktree và baseline

1. Không bắt đầu đại refactor trong worktree đang có nhiều thay đổi chưa commit, đặc biệt ở `travel_api_service.dart`, `sync_service.dart`, `app_router.dart` và `tour_detail_screen.dart`.
2. Tách/stage hoặc ghi nhận rõ thay đổi hiện có trước khi chạm vào cùng file.
3. Chạy baseline đầy đủ và ghi kết quả thực tế.

### Giai đoạn 1 — Bootstrap repository, phạm vi hẹp

1. Viết failing test cho các tình huống: online thành công, offline có cache, offline không có cache, logout không lộ dữ liệu private, và chỉ một bootstrap request cho một lần refresh.
2. Tạo `BootstrapRepository` bao bọc API + SQLite + fallback + privacy filtering.
3. Đổi `bootstrapProvider` sang gọi repository mà không đổi public behavior của caller.
4. Chạy test provider/repository và full Flutter test.

### Giai đoạn 2 — Routing theo flow

1. Lập danh sách từng `Navigator.push` cùng mục đích và dữ liệu truyền vào.
2. Chỉ migrate flow độc lập có route contract rõ ràng.
3. Thêm test cho auth redirect, deep link/back behavior và params không hợp lệ.
4. Giữ Navigator cho transient flow cho đến khi có thiết kế tương đương.

### Giai đoạn 3 — Tách `TourDetail` theo section

1. Xác định section có trách nhiệm rõ: header, booking controls, itinerary, map và payment handoff.
2. Giữ local state cục bộ nếu không có nhu cầu chia sẻ; chỉ tạo notifier khi có invariant/logic domain cần test độc lập.
3. Viết widget test cho thay đổi số khách, ngày, tổng giá, state lịch trình và handoff booking.
4. Không đặt mục tiêu số dòng cố định; mục tiêu là locality và testability.

### Giai đoạn 4 — Socket và performance, chỉ khi có bằng chứng

1. Bổ sung `SocketService` sau một interface tương thích nếu lifecycle hiện tại thực sự gây lỗi quan sát được.
2. Profile Dashboard trước khi chuyển sang sliver; lưu trace/metric làm bằng chứng.
3. Không đưa WorkManager vào scope nếu chưa có yêu cầu background-sync được phê duyệt.

## Verification bắt buộc

Mỗi giai đoạn phải ghi rõ test mới, command và expected result. Tối thiểu:

```powershell
flutter analyze
flutter test
git diff --check
```

Nếu chạm đến socket protocol hoặc API/backend contract, chạy thêm từ `backend`:

```powershell
npm run db:validate
npm run build
npm test
```

Manual verification phải bao gồm: đăng nhập/đăng xuất, offline có cache, offline không cache, refresh token, reconnect/rejoin room, redirect auth, back navigation và booking thành công/thất bại.

## Tiêu chí chấp nhận kế hoạch mới

- Phạm vi được chia thành các giai đoạn độc lập, có thể deploy/test riêng.
- Không có placeholder như "v.v.", "tất cả màn hình" hoặc "xóa sạch".
- Có file path, interface/contract, migration order, test case và command cụ thể cho từng task.
- Không làm mất các hardening hiện có của bootstrap, auth refresh, offline privacy, socket reconnect hoặc checkout.
- Không thay đổi kiến trúc chỉ vì sở thích; mỗi refactor phải có lỗi, metric hoặc chi phí bảo trì cụ thể làm bằng chứng.
