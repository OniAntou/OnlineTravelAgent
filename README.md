# Online Travel Agent

Ứng dụng đặt và quản lý du lịch gồm Flutter mobile app, backend Express/TypeScript và PostgreSQL.

## Tech Stack

### Mobile

- Flutter 3.44
- Riverpod cho state management
- Drift/SQLite cho local database và offline-first cache
- `flutter_secure_storage` cho token
- `socket_io_client` cho realtime trip schedule
- `easy_localization` cho đa ngôn ngữ

### Backend

- Node.js 24 LTS
- Express 5 + TypeScript strict mode
- PostgreSQL + Prisma
- Zod validation
- JWT authentication
- Socket.IO realtime
- Helmet, CORS whitelist, rate limit

## Yêu Cầu

- Flutter 3.44
- Node.js 24 + npm 11
- PostgreSQL

Backend dùng `.nvmrc`, có thể chạy:

```bash
nvm use
```

## Setup Backend

```bash
cd backend
npm ci
cp .env.example .env
npm run db:generate
npm run db:migrate
npm run dev
```

Backend mặc định chạy tại `http://localhost:3000`.

Biến môi trường quan trọng:

- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET`: secret ký JWT
- `ADMIN_PASSWORD`: mật khẩu Basic Auth cho admin panel
- `CORS_ORIGINS`: danh sách origin được phép, phân tách bằng dấu phẩy
- `TRUST_PROXY`: đặt `1` nếu backend chạy sau đúng một reverse proxy
- `UPLOAD_DIR`: tùy chọn, thư mục lưu file upload

## Setup Flutter

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

API URL mặc định:

- Android emulator: `http://10.0.2.2:3000`
- Desktop/Web/iOS simulator: `http://localhost:3000`

Override bằng `dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=http://<your-ip>:3000
```

## Scripts

Backend:

```bash
npm run build
npm test
npm run db:validate
npm run db:migrate
npm run db:seed
```

Flutter:

```bash
flutter analyze
flutter test
```

## Docker Backend

Build image:

```bash
docker build -t online-travel-agent-backend ./backend
```

Run container:

```bash
docker run --rm -p 3000:3000 \
  -e DATABASE_URL="postgresql://user:password@host:5432/online_travel_agent?schema=public" \
  -e JWT_SECRET="change-me" \
  -e ADMIN_PASSWORD="change-me" \
  -e CORS_ORIGINS="http://localhost:3000" \
  online-travel-agent-backend
```

Chạy migration trước khi deploy production:

```bash
cd backend
npm run db:migrate
```

## CI

GitHub Actions chạy:

- Backend: `npm ci`, Prisma generate/validate, TypeScript build, Vitest, npm audit, Docker build
- Flutter: `flutter pub get`, `flutter analyze`, `flutter test`

## Lưu Ý

- Không dùng `prisma db push` cho production. Dùng migration qua `npm run db:migrate`.
- Payment đang là phần xử lý riêng, không nằm trong phạm vi hardening hiện tại.
