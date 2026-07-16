# Vận hành và phát hành

## Mục tiêu vận hành

Một release an toàn phải bảo đảm bốn điều:

1. Backend có configuration hợp lệ và kết nối PostgreSQL persistent.
2. Migration phù hợp đã được áp dụng trước khi code mới phụ thuộc schema mới.
3. Flutter build trỏ đúng API base URL và CORS cho phép origin cần thiết.
4. Health, auth, booking và các route critical được kiểm bằng môi trường thật phù hợp.

CI không tự deploy, nên phần này là runbook cho người vận hành.

## Production configuration

| Configuration | Yêu cầu vận hành |
|---|---|
| DATABASE_URL | Trỏ PostgreSQL persistent, không phải database disposable/local test. |
| JWT_SECRET | Secret mạnh, khác từng environment, quản lý ngoài source. |
| ADMIN_PASSWORD | Secret mạnh cho admin Basic Auth. |
| CORS_ORIGINS | Explicit allowlist origin frontend/panel cần thiết. |
| TRUST_PROXY | Chỉ bật đúng số proxy phía trước backend. |
| SUPABASE_URL | URL project Storage dùng chung cho ảnh catalogue. |
| SUPABASE_SERVICE_ROLE_KEY | Secret backend-only cho upload; không đưa vào mobile/browser/Git. |
| SUPABASE_STORAGE_BUCKET | `travel-media` trừ khi Storage được cấu hình lại có chủ đích. |
| UPLOAD_DIR | Chỉ phục vụ tương thích URL `/uploads/...` cũ. |
| REQUIRE_ADMIN_BASIC_AUTH | Bật khi static /admin cần được bảo vệ từ lớp file serving. |
| Payment config | Provider key, secret, return/IPN URL đúng public environment. |

Backend env validation yêu cầu JWT_SECRET và ADMIN_PASSWORD ngoài test. Production yêu cầu CORS_ORIGINS; không dùng wildcard để thay hiểu rõ origin policy.

## Release workflow

~~~mermaid
flowchart TD
    PREP["Review code, migration, configuration"] --> VERIFY["Run local/CI validation"]
    VERIFY --> BACKUP["Confirm database backup and recovery point"]
    BACKUP --> MIGRATE["Apply reviewed db:migrate"]
    MIGRATE --> DEPLOY["Deploy backend/static panels"]
    DEPLOY --> HEALTH["GET /health and inspect logs"]
    HEALTH --> SMOKE["Auth, bootstrap, booking/payment sandbox smoke checks"]
    SMOKE --> MOBILE["Release/test Flutter build with correct API base"]
    MOBILE --> MONITOR["Monitor errors, 503s, provider callbacks"]
~~~

### Release steps

1. Đọc migration và kiểm backward compatibility giữa code cũ/mới nếu rollout không atomic.
2. Xác nhận database backup/recovery point theo chính sách vận hành trước khi chạy migration.
3. Cấp environment variables đúng environment.
4. Tại backend release artifact, chạy npm run db:generate nếu build workflow cần và npm run db:migrate.
5. Deploy backend, static panels và xác nhận biến Supabase Storage có mặt ở backend.
6. Gọi GET /health.
7. Test login, refresh, bootstrap, một route public và một protected route.
8. Với release chạm booking/payment, test sandbox/provider callback end-to-end.
9. Với release chạm schedule, test admin update và client realtime refetch bằng hai session.
10. Theo dõi logs/error rate/cache behavior trong thời gian đầu sau release.

## Health và observability

| Surface | Cách quan sát |
|---|---|
| Liveness/basic availability | GET /health. |
| HTTP errors | Backend logs và reverse-proxy/platform logs. |
| Database availability | 503 PersistentDataUnavailableError là tín hiệu database/persistent layer có vấn đề. |
| Auth abuse | Rate-limit response và auth logs. |
| Payment | Provider callback logs, trip payment status/reference. |
| Realtime | Socket connect/join behavior, schedule_updated/refetch logs. |
| Upload | Storage response, size/type rejection, bucket capacity và 502 upload error. |

Winston có mặt trong backend để logging. Chọn log drain/retention/alert theo hạ tầng deploy; code repository không định nghĩa một provider observability bắt buộc.

## Static panels

### Admin

- URL: /admin.
- API: /api/admin.
- API yêu cầu Basic Auth luôn luôn.
- Static panel chỉ được Basic Auth trước khi trả HTML khi REQUIRE_ADMIN_BASIC_AUTH=true.

Khi public deploy, bật bảo vệ static panel hoặc đặt equivalent access control ở reverse proxy. Không xem việc API có Basic Auth là lý do để công khai UI quản trị không chủ đích.

### Partner

- URL: /partner.
- API: /api/partner.
- API yêu cầu JWT role PARTNER hoặc ADMIN.
- Partner controller scope resource theo partnerId.

Không phát hành thêm UI partner action nếu backend route/authorization chưa có capability tương ứng.

## Database safety

| Việc | Quy tắc |
|---|---|
| Thay schema | Migration review trước, không dùng db push production. |
| Deployment có migration | Chạy db:migrate đúng database trước khi code mới yêu cầu field/table mới. |
| Seed | Chỉ dùng có chủ đích ở development/demo, không seed production vô tình. |
| Search index | Nếu deployment cần pg_trgm, áp dụng/verify backend/prisma/pg_trgm.sql theo quy trình database. |
| Restore | Test recovery process theo chính sách hạ tầng trước khi cần sự cố thật. |

## Upload/storage safety

Ảnh mới dùng bucket public `travel-media` trên Supabase Storage. Backend là writer duy nhất bằng service-role key; URL public chỉ cho phép đọc. Không đưa key vào Flutter/static panel và không stage `backend/.env`. `UPLOAD_DIR` cùng route `/uploads` chỉ còn để ảnh database cũ tiếp tục hiển thị; hạ tầng không cần filesystem persistent cho ảnh mới.

Sau một update/delete catalogue thành công, backend xóa ảnh Supabase cũ sau khi Prisma write/transaction đã hoàn tất. Cleanup chỉ nhận URL public thuộc chính project và bucket cấu hình, là best-effort và không được làm request CRUD thất bại. Khi điều tra tăng dung lượng bucket, phân biệt orphan do lỗi cleanup (xem warning backend) với orphan do upload xong nhưng form chưa lưu; loại sau chưa có tác vụ quét tự động.

## Incident behavior

| Sự cố | Hành vi hệ thống | Phản ứng đầu tiên |
|---|---|---|
| PostgreSQL unavailable ở production | Backend trả 503 thay vì memory data. | Kiểm database connectivity, credential, network và logs; không cố chuyển production sang mock. |
| JWT/secret sai | Env validation/startup hoặc auth failure. | Xác nhận secret/environment, không sửa token state trong database mù quáng. |
| CORS block | Browser client gọi API thất bại. | So khớp origin thực tế với CORS_ORIGINS. |
| Rate limit | 429/limit response. | Xác định traffic hợp lệ hay abuse; điều chỉnh policy có review. |
| Payment callback mismatch | Trip giữ PENDING/FAILED hoặc ref không đúng. | Kiểm signature, callback URL, amount, provider logs và server logs. |
| Socket không cập nhật | UI giữ schedule cũ cho tới fetch. | Kiểm token/room ownership/event, sau đó kiểm endpoint schedule. |
| Upload lỗi | Rejection/Storage error. | Kiểm size/type, ba biến Storage, bucket policy/capacity và backend logs; không lộ service-role key. |

## Rollback và compatibility

Repository không định nghĩa một automated deployment/rollback workflow. Vì vậy:

- tránh destructive migration cùng lúc với code release nếu rollback chưa được thiết kế;
- giữ migration additive/compatible khi rollout nhiều instance;
- snapshot/backup database trước migration có rủi ro;
- rollback application version chỉ an toàn khi schema còn tương thích;
- khi payment contract thay đổi, giữ parser/mapping tương thích đủ lâu để xử lý callback đang bay.

## Runtime optimization operational checks

After a deploy that changes catalogue or review mutations, verify that the next authenticated and anonymous bootstrap response reflects the mutation while an unrelated search request can still use its cache. If persistent storage is unavailable, `/health` must show `503` and protected persistence paths must return `503` in production rather than serving memory data.

For mobile releases, test an existing device cache with legacy Vietnamese trip labels as well as a clean install. Both must render canonical pending-payment, upcoming, ongoing, completed, and cancelled states without a Drift migration.

## Production smoke checklist

| Kiểm tra | Mục tiêu |
|---|---|
| GET /health | Server đạt trạng thái phục vụ. |
| CORS từ frontend thật | Origin được allow đúng. |
| Login và refresh | Token lifecycle hoạt động. |
| GET /bootstrap | Persistent data/API contract hoạt động. |
| Protected trip/document endpoint | Ownership/auth hoạt động. |
| Admin/partner access | Panel/API permission đúng role. |
| Upload | Storage path và type/size rules hoạt động. |
| Booking | requestId, Trip persistence và owner state đúng. |
| VNPay/MoMo sandbox nếu thay payment | Callback signature/status/ref đúng. |
| Schedule update nếu thay realtime | Event đến và client refetch schedule đúng. |

## Tương quan với CI

CI pass là điều kiện cần, không đủ cho release. Đặc biệt migration, persistent PostgreSQL, file storage, external payment callbacks, CORS, static panel access và mobile device behavior đều cần môi trường thật/staging hoặc smoke test sau deploy.
