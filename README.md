# UG Movie: Telegram Video Indexer & Streamer

A mobile app built with Flutter and FastAPI that indexes videos uploaded to a private Telegram channel and streams them directly to the client device with support for range seeking.

---

## Features
- **$0 Cost Architecture**: Utilizes Telegram as unlimited cloud storage, Supabase (Free Tier) for Database & Auth, and a FastAPI proxy for chunk-level streaming.
- **Cinematic Dark Theme**: Sleek UI designed for movie browsing.
- **User Authentication**: Secure sign-in and sign-up using Supabase Auth.
- **Admin Indexing**: Easily sync new movies by uploading videos to a Telegram Channel and pressing the Sync button.
- **HTTP Byte-Range Streaming**: Enables smooth video seeking and scrubbing inside the Flutter video player.

---

## Project Structure
```text
ug_movie/
├── backend/                  # Python FastAPI Backend
│   ├── main.py               # Streaming proxy & indexing logic
│   ├── requirements.txt      # Python dependencies
│   └── .env.example          # Environment template
├── lib/                      # Flutter Mobile Client
│   ├── core/                 # Shared configs, themes, and routers
│   └── features/             # App features (Auth, Movies)
├── schema.sql                # Supabase database schema
└── README.md                 # Project guide
```

---

## Getting Started

### 1. Database Setup (Supabase)
1. Go to [Supabase](https://supabase.com) and create a free project.
2. In the Supabase Dashboard, go to **SQL Editor** -> **New Query**.
3. Copy and paste the contents of [schema.sql](file:///home/gumite/Documents/ug_movie/schema.sql) and run it to create the `movies` table and its security policies.

### 2. Backend Setup
1. Create your Telegram API ID and API Hash:
   - Go to [my.telegram.org](https://my.telegram.org) and log in.
   - Go to **API development tools** and create a new application. Note down the `api_id` and `api_hash`.
2. Create a Telegram Bot:
   - Open Telegram and message [@BotFather](https://t.me/BotFather).
   - Use `/newbot` to create a bot and get its `bot_token`.
3. Create a private Telegram Channel:
   - Create a new Channel (or Group) in Telegram.
   - Add your bot to the channel as an **Administrator** with permission to read/write messages.
   - Send any video to the channel with a caption in the format: `Movie Title | Description | Category`
   - Retrieve the channel's ID (typically begins with `-100`).
4. Set up backend environment:
   - Navigate to the `backend/` folder.
   - Copy `.env.example` to `.env`.
   - Fill in your `TELEGRAM_API_ID`, `TELEGRAM_API_HASH`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHANNEL_ID`, and your Supabase Project `URL` & `service_role` key (found in Supabase Settings -> API).
5. Install Python dependencies and run the server:
   ```bash
   cd backend
   pip install -r requirements.txt
   python main.py
   ```
   *Note: During startup, the Telethon client will automatically authenticate using the Bot Token.*

### 3. Flutter App Setup
1. Open [lib/core/network/supabase_config.dart](file:///home/gumite/Documents/ug_movie/lib/core/network/supabase_config.dart).
2. Update the credentials:
   - Set `url` to your Supabase Project URL.
   - Set `anonKey` to your Supabase Anon Key.
   - Set `backendUrl` to your local or deployed FastAPI server IP (e.g., `http://10.0.2.2:8000` for Android emulator or your local machine IP).
3. Run the Flutter app:
   ```bash
   flutter run
   ```
