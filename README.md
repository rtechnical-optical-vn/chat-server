# R Technical Chat Server (Rails + Action Cable)

Live chat backend for [rtechnical](https://github.com/rtechnical-optical-vn/rtechnical), moved from `rtechnical/chat-server` (Node + Socket.IO) to standalone Rails app using [Action Cable](https://guides.rubyonrails.org/action_cable_overview.html).

## Stack

- Ruby on Rails 8 (API-only)
- PostgreSQL (same schema as former Prisma service)
- Action Cable WebSocket at `/cable`
- REST API compatible with existing Next.js proxies

## API (unchanged contract)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| POST | `/api/sessions` | Create chat session |
| GET | `/api/sessions/:id/messages?visitorToken=` | Load messages |
| POST | `/api/sessions/:id/messages` | Visitor message (REST fallback) |
| GET | `/api/admin/sessions` | List sessions (header `x-chat-admin-key`) |
| POST | `/api/admin/sessions/:id/messages` | Staff reply |
| PATCH | `/api/admin/sessions/:id` | Close session |
| WS | `/cable` | Action Cable — `ChatSessionChannel` |

## Docker (Windows / không cần cài Ruby trực tiếp)

**Lưu ý:** Docker Desktop trên Windows vẫn chạy qua **WSL 2** — không thay thế hoàn toàn Ubuntu/WSL.

1. Mở **PowerShell (Run as Administrator)**:
   ```powershell
   wsl --update
   wsl --install -d Ubuntu
   ```
2. Khởi động lại máy, mở Ubuntu một lần để tạo user.
3. Mở Docker Desktop → **Try Again** (đợi Engine chạy xanh).
4. Trong thư mục `chat-server`:
   ```powershell
   cd d:\source\chat-server
   docker compose up --build
   ```
5. Kiểm tra: http://localhost:3002/health

Postgres trong Docker lắng nghe port **5433** (tránh trùng Postgres cài sẵn trên máy).

## Local dev (Ruby trực tiếp)

```bash
cd chat-server
cp .env.example .env
bundle install
bundle exec rails db:migrate
bundle exec rails server -p 3002
```

In `rtechnical/.env.local`:

```env
CHAT_API_URL=http://localhost:3002
NEXT_PUBLIC_CHAT_API_URL=http://localhost:3002
CHAT_ADMIN_API_KEY=your-key
```

## Deploy (Render)

Set **Root Directory** to `chat-server` (repo root layout) or deploy this folder as its own repo.
