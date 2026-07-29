# Kiến trúc hệ thống

## Mục tiêu

Phần này trả lời bốn câu hỏi:

1. Thành phần nào tồn tại trong hệ thống?
2. Thành phần nào sở hữu state và dữ liệu?
3. Chúng liên lạc với nhau qua giao thức nào?
4. Cần đọc file nào trước khi thay đổi một khu vực?

## System context

~~~mermaid
flowchart LR
    U["Khách hàng"] --> M["Flutter mobile app"]
    A["Quản trị viên"] --> AP["Static Admin panel"]
    P["Đối tác"] --> PP["Static Partner panel"]

    M -->|"HTTPS REST /api"| B["Express API"]
    M <-->|"Socket.IO"| B
    M -->|"secure tokens"| SS["Flutter Secure Storage"]
    M -->|"cache snapshot"| SQ["Drift / SQLite"]

    AP -->|"Admin API"| B
    PP -->|"Partner API"| B
    B -->|"Prisma"| DB[("PostgreSQL")]
    B -->|"signed request/callback"| PAY["VNPay"]
    B -->|"file storage path"| UP["Uploads directory"]
~~~

## Ranh giới trách nhiệm

| Layer | Sở hữu | Không nên sở hữu |
|---|---|---|
| Flutter presentation | Màn hình, input, loading/error state, điều hướng cục bộ. | Quyền truy cập, số tiền giao dịch cuối cùng, trạng thái payment cuối cùng. |
| Flutter application/state | Riverpod providers, optimistic UI, orchestration bootstrap/sync. | Persistent transaction hay authorization. |
| Flutter data | HTTP client, secure storage, Drift cache, socket lifecycle. | Business rule chỉ được server tin cậy. |
| Express modules | Validation, authorization, transaction, payment verification, event emission. | State hiển thị widget hoặc cache UI riêng lẻ. |
| Prisma/PostgreSQL | Dữ liệu bền vững, foreign key/unique/index, lịch sử quan hệ. | UI projection không cần lưu hoặc token plaintext. |
| Admin/Partner panels | Quản trị/thao tác dữ liệu qua API. | Bỏ qua authorization ở server. |

## Luồng dữ liệu chính

1. Flutter đọc cache SQLite để hiển thị dữ liệu càng sớm càng tốt.
2. Flutter lấy bootstrap payload mới qua REST.
3. Express đọc/ghi PostgreSQL qua Prisma và trả DTO JSON.
4. Flutter ghi snapshot mới vào SQLite, sau đó Riverpod providers render UI.
5. Khi lịch trình đổi, server phát Socket.IO event; client refetch API thay vì xem socket payload là source of truth.
6. Booking/payment luôn được server kiểm ownership, amount và trạng thái.

## Các tài liệu chi tiết

| Tài liệu | Khi cần đọc |
|---|---|
| [Mobile client](mobile-client.md) | Sửa Flutter UI, Riverpod, router, cache hay app lifecycle. |
| [Backend và API](backend-and-api.md) | Sửa route, controller, middleware, Socket.IO, static panel. |
| [Dữ liệu, bảo mật và integration](data-security-and-integrations.md) | Sửa Prisma schema/migration, auth, payment, upload, secrets. |

## Cây thư mục đáng chú ý

~~~text
.
├── lib/                    Flutter application
│   ├── app/                app-level lifecycle và shell
│   ├── core/               router, constants, theme, utilities
│   ├── data/               remote, local Drift, services
│   ├── features/           use case và presentation theo domain
│   ├── screens/            màn hình dùng chung/legacy composition
│   └── shared/             widget và infrastructure dùng chung
├── test/                   Flutter unit/widget tests
├── backend/
│   ├── src/core/           config, middleware, logger, cache
│   ├── src/infrastructure/ Prisma/memory data availability
│   ├── src/modules/        feature modules của API
│   ├── prisma/             schema, migrations, seed, search SQL
│   ├── tests/              Vitest/Supertest tests
│   ├── admin/              static admin panel
│   └── partner/            static partner panel
├── assets/                 images và translations
└── .github/workflows/      CI
~~~

## Nguyên tắc kiến trúc đã thể hiện trong code

- Server là authority cho dữ liệu user-owned, booking và payment.
- Bootstrap snapshot là bridge giữa server data và UI/cache.
- Token được lưu trong secure storage; refresh được serialize ở HTTP client.
- Cache offline là cache xem dữ liệu, không phải transactional offline booking system.
- Socket.IO báo hiệu thay đổi; REST/database xác nhận state.
- Prisma migration là con đường thay đổi schema production; không dùng db push cho production.
- Mỗi partner được scope bằng partnerId server-side; mỗi user chỉ truy cập trip/tài liệu của mình.

## Runtime optimization contracts

The implementation record for the runtime/data-flow optimization is kept in [plans](../plans/2026-07-16-runtime-and-dataflow-optimization.md), alongside its [completed checklist](../plans/2026-07-16-runtime-and-dataflow-optimization-plan.md). Keep the stable contracts in this directory up to date when that implementation changes.

## Entry points

| Thành phần | Entry point |
|---|---|
| Flutter | lib/main.dart |
| Flutter router | lib/core/router/app_router.dart |
| Backend server | backend/src/server.ts |
| Express app | backend/src/app.ts |
| API mounting | backend/src/modules/routes.ts |
| Database schema | backend/prisma/schema.prisma |
| CI | .github/workflows/ci.yml |
