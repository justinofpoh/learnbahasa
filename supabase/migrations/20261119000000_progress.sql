-- Learn Bahasa: accounts and synced progress.
-- Run once in Supabase › SQL Editor. Safe to re-run.

-- One row per learner. `data` is the merged progress document both the app and the website read and write:
-- {
--   "v": 1,
--   "lessons": ["1.1", ...],                       -- lessons finished
--   "xp": 120,
--   "chats": { "id.warung.lunch": { "stars": 2, "lived": true } },
--   "profile": { "name", "country", "city", "avatar", "level", "updatedAt" },
--   "app": { "rehearsal": {...}, "progress": {...}, "updatedAt": "..." }   -- full iPhone backup
-- }
create table if not exists public.progress (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.progress enable row level security;

drop policy if exists "read own progress"   on public.progress;
drop policy if exists "insert own progress" on public.progress;
drop policy if exists "update own progress" on public.progress;

create policy "read own progress"   on public.progress for select using (auth.uid() = user_id);
create policy "insert own progress" on public.progress for insert with check (auth.uid() = user_id);
create policy "update own progress" on public.progress for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Lets a signed-in learner delete their own account and everything with it (App Store rule 5.1.1(v)).
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if auth.uid() is null then
    raise exception 'Not signed in';
  end if;
  delete from public.progress where user_id = auth.uid();
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
