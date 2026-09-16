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

## Docker (Windows / no need to install Ruby directly)

**Note:** Docker Desktop on Windows still run via **WSL 2** — it does not completely replace Ubuntu/WSL.

1. Open **PowerShell (Run as Administrator)**:
   ```powershell
   wsl --update
   wsl --install -d Ubuntu
   ```
2. Restart the PC, and launch Ubuntu once to create a user.
3. Open Docker Desktop → **Try Again** (wait Engine to turn green).
4. In the `chat-server` directory:
   ```powershell
   cd d:\source\chat-server
   docker compose up --build
   ```
5. Check: http://localhost:3002/health

Postgres in Docker listen port **5433** (avoid with Postgres based on your PC).

## Local dev (Ruby direct)

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
