# Online Travel Agent

Ứng dụng Flutter quản lý du lịch với backend `Express.js + TypeScript` và database `PostgreSQL`.

## Tech Stack

### Frontend (Flutter)
- **State Management**: Riverpod 3.3.1
- **Local Database**: drift (SQLite) + sqlite3_flutter_libs
- **Connectivity**: connectivity_plus
- **UI**: flutter_map, cached_network_image, shimmer, animated_text_kit
- **Storage**: flutter_secure_storage

### Backend (Express.js)
- Runtime: Node.js + TypeScript
- Database: PostgreSQL + Prisma 6.19
- Auth: JWT (jsonwebtoken)
- Realtime: Socket.IO

## Architecture

```
┌─────────────────────────────────────────────────┐
│                   Flutter App                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │ Providers │  │  Screens │  │   Services   │  │
│  │ (Riverpod)│  │          │  │              │  │
│  └────┬─────┘  └──────────┘  └──────┬───────┘  │
│       │                             │           │
│  ┌────▼─────────────────────────────▼───────┐  │
│  │              SQLite (drift)               │  │
│  │  11 tables: destinations, categories,     │  │
│  │  hotels, rooms, tours, trips, reviews...  │  │
│  └────────────────────┬─────────────────────┘  │
│                       │                         │
│  ┌────────────────────▼─────────────────────┐  │
│  │           SyncService                     │  │
│  │  - Periodic sync (5 min)                  │  │
│  │  - Event-based sync (reconnect, action)   │  │
│  │  - Server wins conflict resolution        │  │
│  └────────────────────┬─────────────────────┘  │
└───────────────────────┼─────────────────────────┘
                        │ HTTP/WebSocket
                ┌───────▼───────┐
                │  Express.js   │
                │  PostgreSQL   │
                └───────────────┘
```

## Offline Support

App hoạt động offline với SQLite (drift):
- **SQLite-first**: App khởi động đọc từ SQLite ngay lập tức
- **Background sync**: Tự động đồng bộ khi có mạng
- **Optimistic updates**: Cập nhật UI ngay, rollback nếu API lỗi
- **Server wins**: Xung đột ưu tiên server

11 bảng SQLite:
- Destinations, Categories, Hotels, Rooms
- TourPackages, Trips, Reviews, Documents
- TripScheduleDays, TripScheduleItems, TripScheduleUpdates

## Setup

### 1. Backend

```bash
cd backend
npm install
npm run dev
```

Backend chạy tại `http://localhost:3000`.

### 2. Flutter

```bash
flutter pub get
dart run build_runner build  # Tạo drift generated code
flutter run
```

API URL mặc định:
- Android emulator: `http://10.0.2.2:3000`
- iOS simulator / Web: `http://localhost:3000`

Override bằng `dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=http://<your-ip>:3000
```

### 3. Tạo lại drift code

Sau khi sửa drift tables/daos:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## API Endpoints

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/health` | Kiểm tra server |
| GET | `/api/bootstrap` | Bootstrap data (destinations, categories, hotels...) |
| PATCH | `/api/destinations/:id/favorite` | Thêm/bỏ yêu thích |
| POST | `/api/trips/book` | Đặt chuyến đi |
| PUT | `/api/profile` | Cập nhật profile |
| POST | `/api/documents` | Thêm giấy tờ |

## Project Structure

```
lib/
├── core/           # Theme, constants
├── database/       # drift tables, DAOs, AppDatabase
│   ├── tables/     # 11 table definitions
│   ├── daos/       # 11 Data Access Objects
│   └── app_database.dart
├── models/         # Data models
├── providers/      # Riverpod providers
├── screens/        # UI screens
├── services/       # API, sync, connectivity
│   ├── sync_service.dart
│   └── connectivity_service.dart
├── utils/          # Helpers
└── main.dart       # Entry point
```
