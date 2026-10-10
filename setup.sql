-- Mission Athletics Jiu Jitsu Tournament Calendar: one-time Supabase setup
-- Run this in the SAME Supabase project as the wrestling calendar:
-- SQL Editor > New query > paste this whole file > Run.
-- It creates separate jiu jitsu tables and a separate coach list.
-- It does not touch the wrestling tables, and it is safe to run again.

-- 1. Tables ---------------------------------------------------------------
create table if not exists public.bjj_coaches (
  email text primary key
);

create table if not exists public.bjj_tournaments (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.bjj_athletes (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

-- 2. Who counts as a jiu jitsu coach (sign-in email is in bjj_coaches)
create or replace function public.is_bjj_coach()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.bjj_coaches
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
grant execute on function public.is_bjj_coach() to anon, authenticated;

-- 3. Access: the calendar can reach the tables; security rules below decide who may change them
grant usage on schema public to anon, authenticated;
grant select on public.bjj_tournaments, public.bjj_athletes to anon, authenticated;
grant insert, update, delete on public.bjj_tournaments, public.bjj_athletes to authenticated;

-- 4. Security rules: everyone can read the schedule, only jiu jitsu coaches can change it
alter table public.bjj_coaches     enable row level security;
alter table public.bjj_tournaments enable row level security;
alter table public.bjj_athletes    enable row level security;

drop policy if exists "Anyone can read bjj tournaments" on public.bjj_tournaments;
create policy "Anyone can read bjj tournaments" on public.bjj_tournaments
  for select using (true);
drop policy if exists "BJJ coaches can change tournaments" on public.bjj_tournaments;
create policy "BJJ coaches can change tournaments" on public.bjj_tournaments
  for all to authenticated using (public.is_bjj_coach()) with check (public.is_bjj_coach());

drop policy if exists "Anyone can read bjj athletes" on public.bjj_athletes;
create policy "Anyone can read bjj athletes" on public.bjj_athletes
  for select using (true);
drop policy if exists "BJJ coaches can change athletes" on public.bjj_athletes;
create policy "BJJ coaches can change athletes" on public.bjj_athletes
  for all to authenticated using (public.is_bjj_coach()) with check (public.is_bjj_coach());
-- (bjj_coaches has no policies on purpose: it can only be edited here in Supabase.)

-- 5. Live updates, so open pages refresh when a coach saves
do $$
begin
  begin alter publication supabase_realtime add table public.bjj_tournaments; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.bjj_athletes;    exception when duplicate_object then null; end;
end $$;

-- 6. Approved jiu jitsu coaches. Add one line per coach email.
insert into public.bjj_coaches (email) values
  ('george@missionathletics.com')
on conflict (email) do nothing;
