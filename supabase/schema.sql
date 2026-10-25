-- CountryApp — esquema de Supabase
-- Ejecutar completo en el SQL Editor del proyecto (Dashboard → SQL Editor → New query).
-- Es idempotente: se puede volver a correr sin romper datos existentes.

-- =========================================================
-- Tablas
-- =========================================================

create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  nickname text unique not null check (char_length(nickname) between 3 and 20),
  full_name text,
  -- Mismo código que el asset de bandera de la app ("pe", "gb-nir").
  country_code text not null,
  avatar_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.game_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles on delete cascade,
  -- Generado en el dispositivo: los reintentos offline no duplican partidas.
  client_id uuid not null unique,
  game_type text not null check (game_type in ('flag', 'capital')),
  -- 20 preguntas × 1000 puntos máximo.
  score int not null check (score between 0 and 20000),
  correct_count int not null check (correct_count >= 0),
  wrong_count int not null check (wrong_count >= 0),
  skipped_count int not null check (skipped_count >= 0),
  duration_seconds double precision not null check (duration_seconds >= 0),
  created_at timestamptz not null default now()
);

create index if not exists game_sessions_type_user_idx on public.game_sessions (game_type, user_id);
create index if not exists game_sessions_user_created_idx on public.game_sessions (user_id, created_at desc);

-- =========================================================
-- Alta de perfil al registrarse
-- La app manda nickname / full_name / country_code en `options.data` del signUp.
-- =========================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, nickname, full_name, country_code)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'nickname', 'user_' || left(new.id::text, 8)),
    new.raw_user_meta_data ->> 'full_name',
    coalesce(new.raw_user_meta_data ->> 'country_code', 'pe')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =========================================================
-- RLS
-- =========================================================

alter table public.profiles enable row level security;
alter table public.game_sessions enable row level security;

drop policy if exists "profiles_select_all" on public.profiles;
create policy "profiles_select_all" on public.profiles
  for select using (true);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "sessions_insert_own" on public.game_sessions;
create policy "sessions_insert_own" on public.game_sessions
  for insert with check (auth.uid() = user_id);

drop policy if exists "sessions_select_own" on public.game_sessions;
create policy "sessions_select_own" on public.game_sessions
  for select using (auth.uid() = user_id);

-- =========================================================
-- Ranking (público, agregado; no expone partidas individuales)
-- p_game_type = null → total de ambos juegos.
-- =========================================================

create or replace function public.get_leaderboard(p_game_type text default null, p_limit int default 50)
returns table (
  user_id uuid,
  nickname text,
  full_name text,
  country_code text,
  avatar_url text,
  total_score bigint,
  games_played bigint,
  rank bigint
)
language sql
stable
security definer set search_path = public
as $$
  select
    p.id,
    p.nickname,
    p.full_name,
    p.country_code,
    p.avatar_url,
    sum(s.score)::bigint as total_score,
    count(*)::bigint as games_played,
    rank() over (order by sum(s.score) desc)::bigint as rank
  from public.game_sessions s
  join public.profiles p on p.id = s.user_id
  where p_game_type is null or s.game_type = p_game_type
  group by p.id
  order by total_score desc, p.nickname asc
  limit greatest(1, least(p_limit, 200));
$$;

-- Posición del usuario actual (aunque no esté en el top). Vacío si no jugó.
create or replace function public.get_my_rank(p_game_type text default null)
returns table (total_score bigint, games_played bigint, rank bigint)
language sql
stable
security definer set search_path = public
as $$
  with totals as (
    select
      s.user_id,
      sum(s.score)::bigint as total_score,
      count(*)::bigint as games_played,
      rank() over (order by sum(s.score) desc)::bigint as rank
    from public.game_sessions s
    where p_game_type is null or s.game_type = p_game_type
    group by s.user_id
  )
  select total_score, games_played, rank from totals where user_id = auth.uid();
$$;

grant execute on function public.get_leaderboard(text, int) to anon, authenticated;
grant execute on function public.get_my_rank(text) to authenticated;

-- =========================================================
-- Storage: avatares en bucket público, cada usuario solo escribe en su carpeta {uid}/
-- =========================================================

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "avatars_public_read" on storage.objects;
create policy "avatars_public_read" on storage.objects
  for select using (bucket_id = 'avatars');

drop policy if exists "avatars_insert_own" on storage.objects;
create policy "avatars_insert_own" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "avatars_update_own" on storage.objects;
create policy "avatars_update_own" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "avatars_delete_own" on storage.objects;
create policy "avatars_delete_own" on storage.objects
  for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);
