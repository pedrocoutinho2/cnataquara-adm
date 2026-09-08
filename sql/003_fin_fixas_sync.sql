-- 003 · 2026-09-08 · CNA ADM
-- Despesa fixa e todo mes: geracao automatica e idempotente, sem botao manual.
-- Ver 50-decisoes/2026-09-08-adm-fixa-e-todo-mes.md

alter table public.fin_despesas_recorrentes
  add column if not exists inicio_competencia text,
  add column if not exists fim_competencia text;

comment on column public.fin_despesas_recorrentes.inicio_competencia is
  'AAAA-MM. Primeira competencia em que a fixa passa a ser gerada. NULL = desde sempre.';
comment on column public.fin_despesas_recorrentes.fim_competencia is
  'AAAA-MM. Ultima competencia em que a fixa e gerada. NULL = sem fim.';

create table if not exists public.fin_recorrente_skip(
  recorrente_id bigint not null references public.fin_despesas_recorrentes(id) on delete cascade,
  competencia   text   not null,
  motivo        text,
  criado_em     timestamptz not null default now(),
  primary key (recorrente_id, competencia)
);

alter table public.fin_recorrente_skip enable row level security;
drop policy if exists "fin aprovados skip" on public.fin_recorrente_skip;
create policy "fin aprovados skip" on public.fin_recorrente_skip
  for all to authenticated using (fin_is_aprovado()) with check (fin_is_aprovado());

create unique index if not exists fin_lancamentos_recorrente_comp_uidx
  on public.fin_lancamentos (unidade, competencia, recorrente_id)
  where recorrente_id is not null;

create or replace function public.fin_fixas_sync(p_unidade text, p_competencia text)
returns integer
language plpgsql
set search_path = public
as $fn$
declare
  n int := 0;
  ld int;
begin
  if p_competencia !~ '^\d{4}-(0[1-9]|1[0-2])$' then
    raise exception 'competencia invalida: %', p_competencia;
  end if;

  ld := extract(day from (date_trunc('month', to_date(p_competencia || '-01','YYYY-MM-DD'))
                          + interval '1 month' - interval '1 day'))::int;

  insert into fin_lancamentos
    (unidade, competencia, tipo, origem, recorrente_id, nome, categoria,
     tipo_despesa, valor_cents, vencimento, responsavel, obs, status)
  select r.unidade, p_competencia, 'despesa', 'recorrente', r.id, r.nome, r.categoria,
         'fixa', coalesce(r.valor_cents, 0),
         case when r.dia_vencimento is null then null
              else to_date(p_competencia || '-' || lpad(least(r.dia_vencimento, ld)::text, 2, '0'),
                           'YYYY-MM-DD') end,
         r.responsavel, r.obs, 'pendente'
    from fin_despesas_recorrentes r
   where r.unidade = p_unidade
     and r.ativo
     and coalesce(r.tipo_despesa,'fixa') = 'fixa'
     and (r.inicio_competencia is null or p_competencia >= r.inicio_competencia)
     and (r.fim_competencia    is null or p_competencia <= r.fim_competencia)
     and not exists (select 1 from fin_lancamentos l
                      where l.unidade = r.unidade
                        and l.competencia = p_competencia
                        and l.recorrente_id = r.id)
     and not exists (select 1 from fin_recorrente_skip s
                      where s.recorrente_id = r.id
                        and s.competencia = p_competencia)
  on conflict do nothing;

  get diagnostics n = row_count;
  return n;
end;
$fn$;

comment on function public.fin_fixas_sync(text, text) is
  'Materializa as despesas fixas ativas na competencia informada. Idempotente. Respeita vigencia e fin_recorrente_skip.';

grant execute on function public.fin_fixas_sync(text, text) to authenticated;

-- backfill executado em 2026-09-08 (julho e agosto ficaram de fora de proposito: meses fechados)
-- select u.unidade, c.comp, fin_fixas_sync(u.unidade, c.comp)
--   from (values ('taquara'),('queimados')) u(unidade),
--        (values ('2026-09'),('2026-10'),('2026-11'),('2026-12')) c(comp);

notify pgrst, 'reload schema';
