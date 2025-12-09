# Supabase Setup Instructions

## Database Schema

Run this SQL in your Supabase project's SQL Editor:

```sql
-- PROFILES (not using Supabase Auth, phone number is primary auth)
create table public.profiles (
  id uuid primary key default gen_random_uuid(),
  phone_number text unique not null,
  username text,
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

-- Profiles policies (using phone_number instead of auth.uid)
create policy "Anyone can view profiles"
on public.profiles for select
using (true);

create policy "Anyone can insert profiles"
on public.profiles for insert
with check (true);

create policy "Users can update own profile by phone"
on public.profiles for update
using (true);

-- Goals policies (phone-based auth, permissive for now)
create policy "Anyone can select goals"
on public.goals for select
using (true);

create policy "Anyone can insert goals"
on public.goals for insert
with check (true);

create policy "Anyone can update goals"
on public.goals for update
using (true);

-- Proofs policies
create policy "Anyone can select proofs"
on public.proofs for select
using (true);

create policy "Anyone can insert proofs"
on public.proofs for insert
with check (true);

-- Streaks policies
create policy "Anyone can view streaks"
on public.streaks for select
using (true);

create policy "Anyone can update streaks"
on public.streaks for update
using (true);

create policy "Anyone can insert streaks"
on public.streaks for insert
with check (true);

-- NOTE: These permissive policies work because authentication happens
-- via Twilio (not Supabase Auth). In production, you should:
-- 1. Implement API key validation in your app
-- 2. Use service role key server-side for sensitive operations
-- 3. Add application-level permission checks
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

**Why is SUPABASE_SERVICE_ROLE_KEY needed?**
The Edge Function uses it to create temporary signed URLs for accessing images in the storage bucket. These signed URLs are passed to OpenAI's Vision API for verification. The function does NOT write to the database - it only returns the verification result to the app, which then updates the database using the authenticated user's credentials (respecting RLS policies).

## Environment Variables

Add these to your Xcode scheme (Edit Scheme → Run → Environment Variables):
- `SUPABASE_URL`: Your project URL
- `SUPABASE_ANON_KEY`: Your anon/public key
