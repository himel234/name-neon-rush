-- Candle Racer leaderboard (works in the SAME Supabase project as Candle Runner) setup
-- Paste all of this into Supabase > SQL Editor > New query, then click "Run".

create table if not exists public.race_scores (
  player_id  uuid primary key,
  name       text not null check (char_length(name) between 1 and 16),
  score      integer not null check (score >= 0 and score <= 10000000),
  coins      integer not null default 0,
  updated_at timestamptz not null default now()
);

alter table public.race_scores enable row level security;

-- Everyone can READ the leaderboard (but never sees the secret player_id)
drop policy if exists "public read" on public.race_scores;
create policy "public read" on public.race_scores for select using (true);
revoke all on public.race_scores from anon, authenticated;
grant select (name, score, coins, updated_at) on public.race_scores to anon, authenticated;

-- Players can only save scores through this function.
-- It keeps each player's BEST score, so a bad run never lowers it.
create or replace function public.submit_race_score(p_id uuid, p_name text, p_score int, p_coins int)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  p_name := trim(p_name);
  if char_length(p_name) < 1 or char_length(p_name) > 16 then
    raise exception 'bad name';
  end if;
  if p_score < 0 or p_score > 10000000 then
    raise exception 'bad score';
  end if;
  insert into race_scores (player_id, name, score, coins)
  values (p_id, p_name, p_score, coalesce(p_coins, 0))
  on conflict (player_id) do update set
    name       = excluded.name,
    coins      = case when excluded.score > race_scores.score then excluded.coins else race_scores.coins end,
    score      = greatest(race_scores.score, excluded.score),
    updated_at = case when excluded.score > race_scores.score then now() else race_scores.updated_at end;
end;
$$;

-- Tells a player their position: rank and total players
create or replace function public.get_my_race_rank(p_id uuid)
returns table (rank bigint, total bigint)
language sql
security definer
set search_path = public
as $$
  select
    (select count(*) from race_scores s2 where s2.score > s.score) + 1,
    (select count(*) from race_scores)
  from race_scores s
  where s.player_id = p_id;
$$;

grant execute on function public.submit_race_score(uuid, text, int, int) to anon, authenticated;
grant execute on function public.get_my_race_rank(uuid) to anon, authenticated;
