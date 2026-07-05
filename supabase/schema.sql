-- ================================================================
--  CENTRAL COMERCIAL · MasterInfo — Estrutura do banco (Supabase)
--  Cole tudo isto no Supabase: SQL Editor > New query > Run.
--  Pode rodar de novo sem medo (é idempotente).
-- ================================================================

-- 1) PERFIS: cada login tem um perfil com um "tipo" (papel).
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  nome       text,
  email      text,
  tipo       text not null default 'colaborador'
             check (tipo in ('colaborador','lider','gestor')),
  created_at timestamptz default now()
);

-- 2) CONTEUDO: os cards que aparecem, com "quem ve" (roles).
create table if not exists public.content (
  id         uuid primary key default gen_random_uuid(),
  emoji      text default '📄',
  titulo     text not null,
  descricao  text,
  url        text,
  categoria  text default 'Geral',
  roles      text[] not null default array['colaborador','lider','gestor'],
  ordem      int default 0,
  created_at timestamptz default now()
);

-- 3) Ao criar um login novo, cria o perfil automaticamente.
--    O PRIMEIRO usuario criado vira GESTOR sozinho.
create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer set search_path = public as $$
declare v_tipo text := 'colaborador';
begin
  if not exists (select 1 from public.profiles where tipo = 'gestor') then
    v_tipo := 'gestor';
  end if;
  insert into public.profiles (id, nome, email, tipo)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nome', split_part(new.email,'@',1)),
    new.email,
    v_tipo
  )
  on conflict (id) do nothing;
  return new;
end; $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 4) Funcao auxiliar: o usuario logado e gestor? (evita recursao no RLS)
create or replace function public.is_gestor()
returns boolean
language sql security definer stable set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and tipo = 'gestor');
$$;

-- 5) SEGURANCA (Row Level Security)
alter table public.profiles enable row level security;
alter table public.content  enable row level security;

-- profiles: todos logados leem; so gestor edita/exclui
drop policy if exists p_sel on public.profiles;
create policy p_sel on public.profiles for select to authenticated using (true);
drop policy if exists p_upd on public.profiles;
create policy p_upd on public.profiles for update to authenticated using (public.is_gestor()) with check (public.is_gestor());
drop policy if exists p_del on public.profiles;
create policy p_del on public.profiles for delete to authenticated using (public.is_gestor());

-- content: todos logados leem; so gestor cria/edita/exclui
drop policy if exists c_sel on public.content;
create policy c_sel on public.content for select to authenticated using (true);
drop policy if exists c_ins on public.content;
create policy c_ins on public.content for insert to authenticated with check (public.is_gestor());
drop policy if exists c_upd on public.content;
create policy c_upd on public.content for update to authenticated using (public.is_gestor()) with check (public.is_gestor());
drop policy if exists c_del on public.content;
create policy c_del on public.content for delete to authenticated using (public.is_gestor());

-- 6) CONTEUDO INICIAL (so insere se a tabela estiver vazia)
insert into public.content (emoji, titulo, descricao, url, categoria, roles, ordem)
select * from (values
  ('🧗','Trilha do Calouro','Seu caminho dia a dia no onboarding.','#','Onboarding', array['colaborador','lider','gestor'], 1),
  ('🚀','Onboarding (Aplicador)','Checklist com responsaveis e cronograma.','#','Onboarding', array['lider','gestor'], 2),
  ('📚','Biblioteca de Processos (POPs)','Os 12 POPs do comercial.','#','Processos', array['colaborador','lider','gestor'], 3),
  ('🗓️','Cadencia por Etapa','O follow diario e os 3 toques.','#','Processos', array['colaborador','lider','gestor'], 4),
  ('🧭','Rotina da Lideranca','Ritmo do dia e da semana da lideranca.','#','Lideranca', array['lider','gestor'], 5)
) as v(emoji,titulo,descricao,url,categoria,roles,ordem)
where not exists (select 1 from public.content);

-- Pronto. Agora crie seu login (o primeiro vira gestor).
