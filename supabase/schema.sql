-- Partnership Desk schema. Run once in the Supabase SQL editor (safe to re-run).
-- Each partnership is stored as a JSON document owned by one signed-in user.

create table if not exists public.partnerships (
  id         uuid primary key default gen_random_uuid(),
  owner_id   uuid not null default auth.uid() references auth.users (id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists partnerships_owner_id_idx on public.partnerships (owner_id);

-- Row level security: a user can only see and change their own rows. Anonymous visitors get nothing.
alter table public.partnerships enable row level security;

drop policy if exists "Owners can read their partnerships"   on public.partnerships;
drop policy if exists "Owners can add partnerships"          on public.partnerships;
drop policy if exists "Owners can update their partnerships" on public.partnerships;
drop policy if exists "Owners can delete their partnerships" on public.partnerships;

create policy "Owners can read their partnerships" on public.partnerships
  for select to authenticated using ((select auth.uid()) = owner_id);
create policy "Owners can add partnerships" on public.partnerships
  for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "Owners can update their partnerships" on public.partnerships
  for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "Owners can delete their partnerships" on public.partnerships
  for delete to authenticated using ((select auth.uid()) = owner_id);

-- Live updates across devices (Realtime respects the policies above).
do $$
begin
  if not exists (select 1 from pg_publication_tables
                 where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'partnerships') then
    alter publication supabase_realtime add table public.partnerships;
  end if;
end $$;
