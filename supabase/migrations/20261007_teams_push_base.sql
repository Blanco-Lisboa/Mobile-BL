-- aplicado no banco do TEAM's (lhqjfdexfexpmnoqhbyv) em 07/10/2026
create extension if not exists pg_net with schema extensions;

create table if not exists public.chat_push_inscricao (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null default auth.uid(),
  plataforma text not null default 'web' check (plataforma in ('web','android','ios')),
  endpoint text not null unique,
  p256dh text,
  auth text,
  setores uuid[] not null default '{}',
  aparelho text,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index if not exists chat_push_inscricao_usuario on public.chat_push_inscricao(usuario_id);
alter table public.chat_push_inscricao enable row level security;
create policy chat_push_inscricao_sel on public.chat_push_inscricao for select to authenticated using (usuario_id = auth.uid() and is_interno());
create policy chat_push_inscricao_ins on public.chat_push_inscricao for insert to authenticated with check (usuario_id = auth.uid() and is_interno());
create policy chat_push_inscricao_upd on public.chat_push_inscricao for update to authenticated using (usuario_id = auth.uid()) with check (usuario_id = auth.uid() and is_interno());
create policy chat_push_inscricao_del on public.chat_push_inscricao for delete to authenticated using (usuario_id = auth.uid());
revoke all on public.chat_push_inscricao from anon;

create or replace function public.teams_push_segredo(p_nome text)
returns text language sql security definer set search_path to 'public','vault','pg_temp' as $$
  select decrypted_secret from vault.decrypted_secrets where name = p_nome limit 1;
$$;
revoke all on function public.teams_push_segredo(text) from public, anon, authenticated;
grant execute on function public.teams_push_segredo(text) to service_role;

create or replace function public.teams_push_guardar(p_nome text, p_valor text)
returns void language plpgsql security definer set search_path to 'public','vault','pg_temp' as $$
begin
  if exists (select 1 from vault.secrets where name = p_nome) then
    raise exception 'ja existe';
  end if;
  perform vault.create_secret(p_valor, p_nome);
end $$;
revoke all on function public.teams_push_guardar(text, text) from public, anon, authenticated;
grant execute on function public.teams_push_guardar(text, text) to service_role;

do $$ begin
  if not exists (select 1 from vault.secrets where name = 'teams_push_gatilho') then
    perform vault.create_secret(encode(extensions.gen_random_bytes(32), 'hex'), 'teams_push_gatilho');
  end if;
end $$;
