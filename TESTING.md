# How to Test the Project

Follow these steps to configure, run, and test the video indexing and streaming flow.

---

## Step 1: Database Setup (Supabase)
1. Go to [Supabase](https://supabase.com) and create a free project.
2. In the Supabase Dashboard, select your project and navigate to the **SQL Editor** on the left menu.
3. Click **New Query**, copy the contents of the local [schema.sql](file:///home/gumite/Documents/ug_movie/schema.sql) file, paste it into the editor, and click **Run**. This creates the `movies` table and configures Row Level Security (RLS) policies.
4. Navigate to **Project Settings > API** (gear icon bottom left) and copy the following credentials:
   - **Project URL**
   - **Anon public key**
   - **service_role key** (Needed by the backend to bypass RLS and insert new records).

---

## Step 2: Telegram Setup & Backend Environment
1. **Telegram API Access**:
   - Go to [my.telegram.org](https://my.telegram.org), log in, and navigate to **API development tools**.
   - Create a new application. Copy the `api_id` and `api_hash`.
2. **Create Bot**:
   - Open Telegram, search for [@BotFather](https://t.me/BotFather), and create a new bot using the `/newbot` command.
   - Copy the generated `bot_token`.
3. **Setup Telegram Private Channel**:
   - Create a new Telegram Channel.
   - Add your bot to the channel as an **Administrator** with permission to read/write messages.
   - Copy the channel's ID (e.g. `-100222333444`). *Note: Private channel IDs must start with `-100`.*
4. **Configure Environment File**:
   - Navigate to the `backend/` folder.
   - Rename the file `.env.example` to `.env`.
   - Update it with your credentials:
     ```ini
     TELEGRAM_API_ID=1234567
     TELEGRAM_API_HASH=abcdef0123456789...
     TELEGRAM_CHANNEL_ID=-100222333444
     TELEGRAM_BOT_TOKEN=123456789:ABC...
     SUPABASE_URL=https://abc.supabase.co
     SUPABASE_KEY=eyJhbG...  # Make sure this is the service_role key, NOT the anon key
     PORT=8000
     ```

---

## Step 3: Run the Backend
Open a terminal in the `backend/` folder and run the FastAPI server:
```bash
# 1. Create a virtual environment
python -m venv venv

# 2. Activate the virtual environment
# On Linux/macOS:
source venv/bin/activate
# On Windows (Command Prompt):
venv\Scripts\activate.bat
# On Windows (PowerShell):
.\venv\Scripts\Activate.ps1

# 3. Install dependencies
pip install -r requirements.txt

# 4. Start the server
python main.py
```
*You should see a message saying "Telegram Bot Client started successfully" and "Uvicorn running on http://0.0.0.0:8000".*

---

## Step 4: Configure the Flutter App
1. Open the file [supabase_config.dart](file:///home/gumite/Documents/ug_movie/lib/core/network/supabase_config.dart).
2. Update the credentials using your Supabase API keys:
   - `url`: Set to your **Project URL**.
   - `anonKey`: Set to your **Anon public key**.
   - `backendUrl`: Set to `http://localhost:8000` (or `http://10.0.2.2:8000` if using an Android Emulator).

---

## Step 5: Run the Flutter Client
Open a second terminal at the root of the project `/home/gumite/Documents/ug_movie` and start the mobile client:
```bash
flutter run
```

---

## Step 6: Perform the End-to-End Test
1. **Register**: Sign up in the Flutter App with any email and password.
2. **Upload Video**: Send an `.mp4` video to your Telegram channel. Include a caption in this exact format:
   ```text
   Big Buck Bunny | Classic open source test movie | Animation
   ```
3. **Sync**: Inside the app, click the **Sync** (circular arrows) icon in the top right.
   - The app will show a message: "Synced! 1 new videos indexed."
4. **Stream**: Tap the newly synced movie card, then select **Stream Now**. The video will buffer and begin streaming with seeking capability.
