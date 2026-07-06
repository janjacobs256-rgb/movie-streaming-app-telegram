import os
import re
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Header, HTTPException, Response
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from telethon import TelegramClient, events
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

API_ID = os.getenv("TELEGRAM_API_ID")
API_HASH = os.getenv("TELEGRAM_API_HASH")
BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
CHANNEL_ID = os.getenv("TELEGRAM_CHANNEL_ID")
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

if not all([API_ID, API_HASH, BOT_TOKEN, CHANNEL_ID, SUPABASE_URL, SUPABASE_KEY]):
    logger.warning("Some environment variables are missing! Please check your .env file.")

try:
    API_ID = int(API_ID) if API_ID else None
    CHANNEL_ID = int(CHANNEL_ID) if CHANNEL_ID else None
except ValueError:
    logger.error("TELEGRAM_API_ID and TELEGRAM_CHANNEL_ID must be integers.")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY) if SUPABASE_URL and SUPABASE_KEY else None
tg_client = TelegramClient("bot_session", API_ID, API_HASH) if API_ID and API_HASH else None

auto_indexed_count = 0


async def index_message(message_id: int, caption: str, doc, duration: int = 0) -> bool:
    global auto_indexed_count

    if not supabase:
        logger.error("index_message: supabase client is None")
        return False
    if not CHANNEL_ID:
        logger.error("index_message: CHANNEL_ID is None")
        return False

    logger.info(f"index_message: checking if message {message_id} already exists in DB")
    try:
        existing = supabase.table("movies").select("id").eq("telegram_message_id", message_id).execute()
        if existing.data:
            logger.info(f"index_message: message {message_id} already indexed (id={existing.data[0]['id']}), skipping")
            return False
        logger.info(f"index_message: message {message_id} is new, proceeding to index")
    except Exception as e:
        logger.error(f"index_message: failed to check existing message {message_id}: {e}")
        return False

    title = "Untitled Video"
    description = ""
    category = "General"
    parts = [p.strip() for p in caption.split("|")]
    if len(parts) >= 1 and parts[0]:
        title = parts[0]
    if len(parts) >= 2:
        description = parts[1]
    if len(parts) >= 3:
        category = parts[2]
    logger.info(f"index_message: parsed caption -> title='{title}', desc='{description}', category='{category}'")

    logger.info(f"index_message: doc type={type(doc).__name__}, id={getattr(doc, 'id', 'N/A')}, size={getattr(doc, 'size', 'N/A')}")
    try:
        file_id = str(getattr(doc, 'id', str(message_id)))
        file_size = int(getattr(doc, 'size', 0))
        duration = int(duration)
    except (ValueError, TypeError) as e:
        logger.error(f"index_message: failed to cast doc fields: {e}")
        return False

    movie_data = {
        "title": title,
        "description": description,
        "category": category,
        "telegram_message_id": message_id,
        "telegram_channel_id": CHANNEL_ID,
        "file_id": file_id,
        "file_size": file_size,
        "duration_seconds": duration,
        "thumbnail_url": "",
    }

    logger.info(f"index_message: inserting into Supabase: {movie_data}")
    try:
        result = supabase.table("movies").insert(movie_data).execute()
        logger.info(f"index_message: insert successful, result={result.data}")
    except Exception as e:
        logger.error(f"index_message: Supabase insert failed: {e}")
        return False

    auto_indexed_count += 1
    logger.info(f"index_message: SUCCESS - indexed message {message_id} as '{title}'")
    return True


@asynccontextmanager
async def lifespan(app: FastAPI):
    if tg_client:
        logger.info("Connecting to Telegram...")
        await tg_client.start(bot_token=BOT_TOKEN)

        @tg_client.on(events.NewMessage(chats=CHANNEL_ID))
        async def handle_new_message(event):
            try:
                message = event.message
                logger.info(f"handle_new_message: received message id={message.id}, has_media={message.media is not None}")

                if not message.media:
                    logger.info("handle_new_message: no media, skipping")
                    return

                logger.info(f"handle_new_message: media type={type(message.media).__name__}")

                doc = None
                if hasattr(message.media, 'document') and message.media.document:
                    doc = message.media.document
                    logger.info(f"handle_new_message: found document, mime='{doc.mime_type}', attributes={[type(a).__name__ for a in doc.attributes]}")

                if not doc:
                    logger.info("handle_new_message: no document in media, skipping")
                    return

                mime = doc.mime_type or ""
                is_video = mime.startswith("video/")
                if not is_video:
                    for attr in doc.attributes:
                        if hasattr(attr, 'duration'):
                            is_video = True
                            logger.info(f"handle_new_message: detected video via attribute {type(attr).__name__}")
                            break

                if not is_video:
                    logger.info(f"handle_new_message: not a video (mime='{mime}'), skipping")
                    return

                duration = 0
                for attr in doc.attributes:
                    if hasattr(attr, 'duration'):
                        duration = attr.duration
                        logger.info(f"handle_new_message: duration={duration}s from {type(attr).__name__}")
                        break

                caption = message.message or ""
                logger.info(f"handle_new_message: caption='{caption}', calling index_message")
                await index_message(message.id, caption, doc, duration)

            except Exception as e:
                logger.error(f"handle_new_message: UNHANDLED ERROR: {e}", exc_info=True)

        logger.info("Telegram Bot Client started successfully.")

        try:
            entity = await tg_client.get_entity(CHANNEL_ID)
            logger.info(f"Bot can access channel: {entity.title} (ID: {entity.id})")
        except Exception as e:
            logger.error(f"Bot cannot access the channel. Add the bot as an admin. Error: {e}")

    yield

    if tg_client:
        logger.info("Disconnecting from Telegram...")
        await tg_client.disconnect()


app = FastAPI(
    title="Telegram Video Indexer & Streamer Proxy",
    description="Streams videos from Telegram channel with Range support and indexes them to Supabase.",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def parse_range_header(range_header: str, file_size: int):
    match = re.search(r'bytes=(\d+)-(\d+)?', range_header)
    if not match:
        return 0, file_size - 1
    start = int(match.group(1))
    end = int(match.group(2)) if match.group(2) else file_size - 1
    if end >= file_size:
        end = file_size - 1
    return start, end


async def telegram_file_generator(file_handle, offset: int, end_byte: int, chunk_size: int = 1024 * 1024):
    aligned_offset = (offset // 4096) * 4096
    skip_bytes = offset - aligned_offset
    bytes_to_read = end_byte - offset + 1

    logger.info(f"Streaming from Telegram: offset {offset}, aligned {aligned_offset}, skip {skip_bytes}, length {bytes_to_read}")

    bytes_sent = 0
    first_chunk = True

    async for chunk in tg_client.iter_download(
        file_handle,
        offset=aligned_offset,
        chunk_size=chunk_size,
        request_size=chunk_size,
    ):
        if first_chunk:
            first_chunk = False
            if len(chunk) > skip_bytes:
                data_to_send = chunk[skip_bytes:]
                if bytes_sent + len(data_to_send) > bytes_to_read:
                    data_to_send = data_to_send[:bytes_to_read - bytes_sent]
                yield data_to_send
                bytes_sent += len(data_to_send)
        else:
            data_to_send = chunk
            if bytes_sent + len(data_to_send) > bytes_to_read:
                data_to_send = data_to_send[:bytes_to_read - bytes_sent]
            yield data_to_send
            bytes_sent += len(data_to_send)

        if bytes_sent >= bytes_to_read:
            break


@app.get("/")
def read_root():
    return {"status": "ok", "message": "Telegram Video Proxy is running!"}


@app.post("/index")
async def index_videos():
    if not supabase:
        raise HTTPException(status_code=500, detail="Backend services not configured.")

    global auto_indexed_count
    new_count = auto_indexed_count
    auto_indexed_count = 0
    return {"status": "success", "new_videos_indexed": new_count}


@app.get("/thumbnail/{movie_id}")
async def get_movie_thumbnail(movie_id: str):
    if not tg_client or not supabase:
        raise HTTPException(status_code=500, detail="Backend services not configured.")

    result = supabase.table("movies").select("*").eq("id", movie_id).execute()
    if not result.data:
        raise HTTPException(status_code=404, detail="Movie not found.")

    movie = result.data[0]
    message_id = movie["telegram_message_id"]

    try:
        message = await tg_client.get_messages(CHANNEL_ID, ids=message_id)
        if not message or not message.media:
            raise HTTPException(status_code=404, detail="Message media not found on Telegram.")

        doc = getattr(message.media, 'document', None)
        if not doc:
            raise HTTPException(status_code=404, detail="Message media does not contain a document.")

        if not getattr(doc, 'thumbs', None):
            raise HTTPException(status_code=404, detail="No thumbnail available for this movie.")

        # Download thumbnail to bytes
        thumb_bytes = await tg_client.download_media(doc, file=bytes, thumb=-1)
        if not thumb_bytes:
            raise HTTPException(status_code=404, detail="Failed to download thumbnail from Telegram.")

        return Response(content=thumb_bytes, media_type="image/jpeg")

    except HTTPException:
        raise
    except Exception as e:
        logger.exception(f"Error fetching thumbnail for {movie_id}:")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/stream/{movie_id}")
async def stream_movie(movie_id: str, range_header: str = Header(None, alias="Range")):
    if not tg_client or not supabase:
        raise HTTPException(status_code=500, detail="Backend services not configured.")

    result = supabase.table("movies").select("*").eq("id", movie_id).execute()
    if not result.data:
        raise HTTPException(status_code=404, detail="Movie not found.")

    movie = result.data[0]
    message_id = movie["telegram_message_id"]
    file_size = movie["file_size"]

    try:
        message = await tg_client.get_messages(CHANNEL_ID, ids=message_id)
        if not message or not message.media:
            raise HTTPException(status_code=404, detail="Video file not found on Telegram.")

        doc = None
        if hasattr(message.media, 'document') and message.media.document:
            doc = message.media.document

        if not doc:
            raise HTTPException(status_code=404, detail="Message media is not a video.")

        start = 0
        end = file_size - 1
        is_range_request = False

        if range_header:
            is_range_request = True
            start, end = parse_range_header(range_header, file_size)
            if start >= file_size or start > end:
                raise HTTPException(
                    status_code=416,
                    detail="Requested Range Not Satisfiable",
                    headers={"Content-Range": f"bytes */{file_size}"}
                )

        content_length = end - start + 1

        headers = {
            "Accept-Ranges": "bytes",
            "Content-Length": str(content_length),
            "Content-Type": "video/mp4",
        }

        if is_range_request:
            headers["Content-Range"] = f"bytes {start}-{end}/{file_size}"

        return StreamingResponse(
            telegram_file_generator(doc, start, end),
            status_code=206 if is_range_request else 200,
            headers=headers,
            media_type="video/mp4",
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.exception(f"Error streaming movie {movie_id}:")
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=False)
