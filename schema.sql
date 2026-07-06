-- Create a table for movies
create table public.movies (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text,
  category text,
  telegram_message_id bigint not null,
  telegram_channel_id bigint not null,
  file_id text not null,
  file_size bigint not null,
  duration_seconds integer,
  thumbnail_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Set up Row Level Security (RLS) for movies
alter table public.movies enable row level security;

-- Create policy to allow all authenticated users to read movie data
create policy "Allow authenticated read access"
  on public.movies
  for select
  to authenticated
  using (true);

-- Create policy to allow admins (or our backend API service role) to insert/update movies
create policy "Allow service_role write access"
  on public.movies
  for all
  using (true)
  with check (true);

-- Create a table for user favorites
create table public.favorites (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  movie_id uuid not null references public.movies(id) on delete cascade,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, movie_id)
);

-- Set up RLS for favorites
alter table public.favorites enable row level security;

-- Allow users to read their own favorites
create policy "Allow users to read their own favorites"
  on public.favorites
  for select
  to authenticated
  using (auth.uid() = user_id);

-- Allow users to insert their own favorites
create policy "Allow users to insert their own favorites"
  on public.favorites
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Allow users to delete their own favorites
create policy "Allow users to delete their own favorites"
  on public.favorites
  for delete
  to authenticated
  using (auth.uid() = user_id);
