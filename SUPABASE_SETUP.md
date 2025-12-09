# Supabase Setup Instructions

## Database Schema

Run this SQL in your Supabase project's SQL Editor:

```sql
-- PROFILES
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  full_name text,
  created_at timestamptz default now()
);

-- GOALS
create table public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  title text not null,
  description text,
  frequency text not null, -- e.g. "daily", "3_per_week"
  is_active boolean default true,
  created_at timestamptz default now()
);

-- STREAKS
create table public.streaks (
  id uuid primary key default gen_random_uuid(),
  goal_id uuid references public.goals(id) on delete cascade,
  current_count int default 0,
  longest_count int default 0,
  last_proof_date date,
  created_at timestamptz default now()
);

-- PROOFS
create table public.proofs (
  id uuid primary key default gen_random_uuid(),
  goal_id uuid references public.goals(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  image_path text not null, -- path in Supabase Storage
  caption text,
  verified boolean default false,
  verification_score numeric,
  created_at timestamptz default now()
);

-- FRIENDSHIPS (simple follow system)
create table public.friendships (
  follower_id uuid references public.profiles(id) on delete cascade,
  following_id uuid references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (follower_id, following_id)
);

-- For social feed convenience: a view that joins proofs with profiles and goals
create view public.proofs_feed as
select
  p.id,
  p.goal_id,
  p.user_id,
  p.image_path,
  p.caption,
  p.verified,
  p.verification_score,
  p.created_at,
  g.title as goal_title,
  pr.username as username
from public.proofs p
join public.goals g on p.goal_id = g.id
join public.profiles pr on p.user_id = pr.id;

-- Enable RLS
alter table public.profiles enable row level security;
alter table public.goals enable row level security;
alter table public.streaks enable row level security;
alter table public.proofs enable row level security;
alter table public.friendships enable row level security;

-- Profiles policies
create policy "Users can view own profile"
on public.profiles for select
using (auth.uid() = id);

create policy "Users can insert own profile"
on public.profiles for insert
with check (auth.uid() = id);

-- Goals policies
create policy "Users can select own goals"
on public.goals for select
using (auth.uid() = user_id);

create policy "Users can insert own goals"
on public.goals for insert
with check (auth.uid() = user_id);

create policy "Users can update own goals"
on public.goals for update
using (auth.uid() = user_id);

-- Proofs policies
create policy "Users can select own proofs"
on public.proofs for select
using (auth.uid() = user_id);

create policy "Users can insert own proofs"
on public.proofs for insert
with check (auth.uid() = user_id);

-- Streaks policies
create policy "Users can view own streaks"
on public.streaks for select
using (exists (
  select 1 from public.goals
  where goals.id = streaks.goal_id
  and goals.user_id = auth.uid()
));

create policy "Users can update own streaks"
on public.streaks for update
using (exists (
  select 1 from public.goals
  where goals.id = streaks.goal_id
  and goals.user_id = auth.uid()
));

create policy "Users can insert own streaks"
on public.streaks for insert
with check (exists (
  select 1 from public.goals
  where goals.id = streaks.goal_id
  and goals.user_id = auth.uid()
));
```

## Storage Bucket

1. Go to Storage in Supabase Dashboard
2. Create a new bucket called `proof-images`
3. Set it to public (or configure policies for authenticated users)

## Edge Function

Create a new Edge Function called `verify-proof` with the code in `supabase/functions/verify-proof/index.ts`

Set these secrets:
```bash
supabase secrets set OPENAI_API_KEY=your_openai_key
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

## Environment Variables

Add these to your Xcode scheme (Edit Scheme → Run → Environment Variables):
- `SUPABASE_URL`: Your project URL
- `SUPABASE_ANON_KEY`: Your anon/public key
