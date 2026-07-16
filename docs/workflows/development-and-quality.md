# Phát triển, kiểm thử và CI

## Prerequisites

| Công cụ | Phiên bản/ghi chú |
|---|---|
| Flutter | 3.44. |
| Dart | Từ 3.10.3 đến dưới 4.0.0. |
| Node.js | 24.x, dùng .nvmrc ở repository root. |
| npm | 11.x. |
| PostgreSQL | Bắt buộc cho backend persistent development. |
| Android emulator hoặc thiết bị | Cần khi kiểm Flutter mobile với API local. |

## Dựng backend local

Chạy từ backend:

~~~powershell
npm ci
Copy-Item .env.example .env
npm run db:generate
npm run db:migrate:dev
npm run db:seed
npm run dev
~~~

Chỉ tạo file .env khi chưa có để không ghi đè secrets cục bộ. Điền DATABASE_URL, JWT_SECRET, ADMIN_PASSWORD, CORS_ORIGINS và các payment config cần thiết theo environment.

### Ý nghĩa backend scripts

| Lệnh | Dùng khi |
|---|---|
| npm ci | Cài dependency theo lockfile, phù hợp CI và local clean install. |
| npm run dev | Chạy tsx watch server và Prisma Studio không mở browser. |
| npm run build | TypeScript compile sang dist. |
| npm start | Chạy dist/server.js sau build. |
| npm run db:generate | Sinh Prisma client. |
| npm run db:validate | Kiểm schema Prisma. |
| npm run db:migrate:dev | Tạo/áp dụng migration ở development. |
| npm run db:migrate | Áp dụng migration đã review ở deploy. |
| npm run db:seed | Seed dữ liệu local/demo. |
| npm run db:studio | Mở Prisma Studio. |
| npm test | Chạy Vitest. |

Không dùng npm run db:push làm workflow production. Mọi thay đổi schema phải đi qua migration được review.

## Dựng Flutter local

Chạy từ repository root:

~~~powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
~~~

API base URL mặc định:

| Target Flutter | API local mặc định |
|---|---|
| Android emulator | http://10.0.2.2:3000 |
| Desktop/Web/iOS simulator | http://localhost:3000 |
| Thiết bị thật | Dùng IP LAN của máy chạy backend qua dart define. |

Ví dụ thiết bị thật:

~~~powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
~~~

Không hard-code địa chỉ LAN vào source. API base được resolve theo platform và dart define.

## Quy trình thay đổi feature

~~~mermaid
flowchart TD
    PLAN["Xác định owner layer và contract"] --> CODE["Sửa source/schema/test"]
    CODE --> GENERATE{"Schema/codegen thay đổi?"}
    GENERATE -- "Flutter Drift" --> BUILD_RUNNER["Run build_runner"]
    GENERATE -- "Prisma" --> PRISMA["Create/apply migration and prisma generate"]
    GENERATE -- "No" --> UNIT["Run focused tests"]
    BUILD_RUNNER --> UNIT
    PRISMA --> UNIT
    UNIT --> FULL["Run full validation suite"]
    FULL --> REVIEW["Review diff and update docs"]
~~~

### Chọn layer trước khi sửa

| Thay đổi | Owner chính |
|---|---|
| Screen/state hành vi UI | Flutter feature/application/presentation. |
| Route/deep link/redirect | lib/core/router. |
| Cache/schema local | Drift tables/DAOs/app database + SyncService. |
| HTTP session/retry | ApiHttpClient và auth services. |
| API input/business rule | Backend route/schema/controller/service. |
| Persistent model | Prisma schema, migration, seed/test. |
| Permission/ownership | Backend middleware/controller, không chỉ UI. |
| Payment/provider callback | Backend payment module trước, Flutter mapping sau. |

## Kiểm thử local

### Flutter

~~~powershell
flutter analyze
flutter test
~~~

Khi cần kiểm app thật, chạy emulator/device smoke test ngoài hai lệnh trên. Build/analyze không chứng minh route, secure storage, API base hay payment redirect hoạt động trên thiết bị.

### Backend

~~~powershell
Set-Location backend
npm run db:generate
npm run db:validate
npm run build
npm test
~~~

Lệnh backend phải chạy trong backend vì package.json/server dependencies không nằm tại repository root.

### Database-backed check

Sau thay schema hoặc query:

~~~powershell
Set-Location backend
npm run db:migrate:dev
npm run db:seed
~~~

Sau đó khởi động server với PostgreSQL thực và kiểm endpoint/booking flow liên quan. Prisma validate/build/unit test không thay thế check migration against a real database.

## Full local verification matrix

| Khu vực thay đổi | Tối thiểu | Khi rủi ro cao |
|---|---|---|
| Flutter UI/provider | flutter analyze; flutter test | Device/emulator smoke test. |
| HTTP/auth/session | Flutter tests; backend tests | Login, refresh, logout với server thật. |
| Drift/sync | Flutter tests | Offline cache/reconnect/logout on device. |
| API/controller | npm run build; npm test | Server + PostgreSQL integration check. |
| Prisma schema/migration | db:generate; db:validate | db:migrate:dev + seed/query check. |
| Socket/schedule | Flutter + backend tests | Hai session thực, update schedule và quan sát refetch. |
| Payment | Backend tests | Sandbox return/IPN with valid signature and mobile result state. |
| Admin/partner panel | Backend tests | Browser smoke test với đúng credentials/roles. |

## GitHub Actions CI

CI file là .github/workflows/ci.yml. Nó chạy khi push hoặc pull request vào main/develop.

| Job | Runtime | Các bước |
|---|---|---|
| Backend | Ubuntu + Node từ .nvmrc | npm ci, Prisma generate, Prisma validate, TypeScript build, Vitest, npm audit mức high. |
| Flutter | Ubuntu + Flutter 3.44 | flutter pub get, flutter analyze, flutter test, debug APK build với API URL example.invalid. |

### Giới hạn của CI hiện tại

- Không khởi tạo PostgreSQL service.
- Không chạy migration/seed lên database thật.
- Không start Express server với môi trường production-like.
- Không chạy browser test Admin/Partner.
- Không chạy Flutter device/emulator E2E.
- Không gọi VNPay/MoMo sandbox hay webhook.
- Không deploy tự động.

Đây là CI cho dependency/build/static/unit integration scope, không phải toàn bộ production validation.

## Code generation checklist

| Khi sửa | Lệnh bắt buộc |
|---|---|
| Drift tables, DAOs hoặc app database | dart run build_runner build --delete-conflicting-outputs. |
| Prisma schema | npm run db:generate; migration workflow thích hợp. |
| Localization assets | Kiểm các translation keys qua Flutter analyze/test và UI smoke test. |

Không commit output build directory hay chỉnh generated .g.dart bằng tay.

## Điều tra lỗi phổ biến

| Triệu chứng | Kiểm tra trước |
|---|---|
| Backend test/build không tìm package | Đã Set-Location backend chưa. |
| Flutter analyzer thiếu package | Chạy flutter pub get trước. |
| API không vào từ Android emulator | Kiểm 10.0.2.2, backend port và firewall. |
| API không vào từ thiết bị thật | Dùng IP LAN/dart define, kiểm CORS/firewall/mạng. |
| Prisma lỗi schema/client | db:generate, db:validate, DATABASE_URL và migration state. |
| CI npm ci lỗi nhưng local khác | Kiểm package-lock với Node/npm version CI, đặc biệt optional dependency khác OS. |
| Lịch không refresh | Kiểm JWT, room join authorization, schedule_updated và API refetch. |

## Tài liệu phải được cập nhật cùng thay đổi

Sau khi thay architecture/workflow, cập nhật file thích hợp trong docs/architecture hoặc docs/workflows trong cùng branch/PR. Với thay đổi có nhiều bước, migration hoặc checklist triển khai, thêm/cập nhật kế hoạch tại docs/plans. Điều này giúp test/code/doc cùng mô tả một contract.
