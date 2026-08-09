-- TCG Tracker — schema Supabase per il sync.
--
-- Da eseguire una volta sola nel SQL Editor del progetto Supabase.
-- È idempotente: rieseguirlo non rompe niente e non cancella dati.
--
-- Il modello è volutamente minimo: un utente, una riga, l'intero database
-- dell'app dentro una colonna jsonb. Il documento è lo stesso identico JSON
-- che l'app esporta col backup manuale, quindi il formato è già versionato e
-- già testato.

create table if not exists public.snapshots (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  revision   bigint      not null default 0,
  payload    jsonb       not null,
  device     text,
  updated_at timestamptz not null default now()
);

alter table public.snapshots enable row level security;

-- Un utente vede e scrive solo la propria riga. È l'unica cosa che separa un
-- account dall'altro: la chiave anon è pubblica e viaggia dentro l'app.
drop policy if exists "snapshots are private" on public.snapshots;
create policy "snapshots are private"
  on public.snapshots
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Scrittura con controllo di revisione.
--
-- Il client dichiara a quale revisione crede che sia il cloud. Se nel
-- frattempo un altro dispositivo ha scritto, il numero non corrisponde più e
-- la funzione rifiuta invece di sovrascrivere: è così che due dispositivi non
-- possono cancellarsi i dati a vicenda in silenzio.
--
-- p_expected = 0 significa "non ho mai sincronizzato con questo account".
create or replace function public.push_snapshot(
  p_payload  jsonb,
  p_expected bigint,
  p_device   text
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user    uuid := auth.uid();
  v_current bigint;
  v_next    bigint;
begin
  if v_user is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;

  select revision into v_current
    from snapshots
   where user_id = v_user
     for update;

  v_current := coalesce(v_current, 0);

  if v_current <> p_expected then
    -- 40001 (serialization_failure) è il codice che il client legge come
    -- "conflitto", per distinguerlo da un errore vero.
    raise exception 'revision mismatch: cloud is at %, client expected %',
      v_current, p_expected using errcode = '40001';
  end if;

  v_next := v_current + 1;

  insert into snapshots (user_id, revision, payload, device, updated_at)
  values (v_user, v_next, p_payload, p_device, now())
  on conflict (user_id) do update
    set revision   = v_next,
        payload    = p_payload,
        device     = p_device,
        updated_at = now();

  return v_next;
end;
$$;

revoke all on function public.push_snapshot(jsonb, bigint, text) from public;
grant execute on function public.push_snapshot(jsonb, bigint, text) to authenticated;
