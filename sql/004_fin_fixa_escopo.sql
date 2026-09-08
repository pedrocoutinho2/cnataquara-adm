-- 004 · 2026-09-08 · CNA ADM
-- Editar/excluir despesa fixa com escopo: 'mes' | 'futuros' | 'todos'.
-- A regra mora no banco porque recalcula vencimento por competencia e
-- precisa proteger lancamento ja pago.

create or replace function public.fin_venc_do_mes(p_competencia text, p_dia int)
returns date language sql immutable as $$
  select case when p_dia is null then null
    else to_date(p_competencia || '-' || lpad(
      least(p_dia, extract(day from (date_trunc('month', to_date(p_competencia||'-01','YYYY-MM-DD'))
             + interval '1 month' - interval '1 day'))::int)::text, 2, '0'), 'YYYY-MM-DD')
  end;
$$;

create or replace function public.fin_fixa_aplicar(
  p_lancamento_id bigint, p_escopo text, p_nome text, p_categoria text,
  p_valor_cents integer, p_dia integer, p_responsavel text, p_obs text
) returns jsonb
language plpgsql
set search_path = public
as $fn$
declare
  l fin_lancamentos%rowtype;
  n_txt int := 0; n_val int := 0;
begin
  if p_escopo not in ('mes','futuros','todos') then
    raise exception 'escopo invalido: %', p_escopo;
  end if;
  select * into l from fin_lancamentos where id = p_lancamento_id;
  if not found then raise exception 'lancamento % nao encontrado', p_lancamento_id; end if;

  update fin_lancamentos
     set nome = p_nome, categoria = p_categoria, valor_cents = coalesce(p_valor_cents,0),
         vencimento = coalesce(fin_venc_do_mes(l.competencia, p_dia), vencimento),
         responsavel = p_responsavel, obs = p_obs
   where id = l.id;

  if p_escopo <> 'mes' and l.recorrente_id is not null then
    update fin_despesas_recorrentes
       set nome = p_nome, categoria = p_categoria, valor_cents = p_valor_cents,
           dia_vencimento = p_dia, responsavel = p_responsavel, obs = p_obs
     where id = l.recorrente_id;

    update fin_lancamentos
       set nome = p_nome, categoria = p_categoria, responsavel = p_responsavel, obs = p_obs
     where recorrente_id = l.recorrente_id and id <> l.id
       and (p_escopo = 'todos' or competencia > l.competencia);
    get diagnostics n_txt = row_count;

    update fin_lancamentos
       set valor_cents = coalesce(p_valor_cents,0),
           vencimento = coalesce(fin_venc_do_mes(competencia, p_dia), vencimento)
     where recorrente_id = l.recorrente_id and id <> l.id and status = 'pendente'
       and (p_escopo = 'todos' or competencia > l.competencia);
    get diagnostics n_val = row_count;
  end if;

  return jsonb_build_object('escopo', p_escopo, 'rotulo', n_txt, 'valor', n_val);
end;
$fn$;

create or replace function public.fin_fixa_excluir(p_lancamento_id bigint, p_escopo text)
returns jsonb
language plpgsql
set search_path = public
as $fn$
declare
  l fin_lancamentos%rowtype;
  n_del int := 0; n_pagos int := 0; encerrada boolean := false;
begin
  if p_escopo not in ('mes','futuros','todos') then
    raise exception 'escopo invalido: %', p_escopo;
  end if;
  select * into l from fin_lancamentos where id = p_lancamento_id;
  if not found then raise exception 'lancamento % nao encontrado', p_lancamento_id; end if;

  if l.recorrente_id is null then
    delete from fin_lancamentos where id = l.id;
    return jsonb_build_object('escopo','mes','apagados',1,'pagos_mantidos',0,'encerrada',false);
  end if;

  if p_escopo = 'mes' then
    insert into fin_recorrente_skip(recorrente_id, competencia, motivo)
    values (l.recorrente_id, l.competencia, 'Excluida na tela de despesas fixas')
    on conflict do nothing;
    delete from fin_lancamentos where id = l.id;
    n_del := 1;
  else
    select count(*) into n_pagos from fin_lancamentos
     where recorrente_id = l.recorrente_id and status = 'pago'
       and (p_escopo = 'todos' or competencia >= l.competencia);

    delete from fin_lancamentos
     where recorrente_id = l.recorrente_id and status = 'pendente'
       and (p_escopo = 'todos' or competencia >= l.competencia);
    get diagnostics n_del = row_count;

    if p_escopo = 'futuros' then
      update fin_despesas_recorrentes
         set fim_competencia = to_char(to_date(l.competencia||'-01','YYYY-MM-DD') - interval '1 month','YYYY-MM')
       where id = l.recorrente_id;
    else
      update fin_despesas_recorrentes set ativo = false, fim_competencia = null
       where id = l.recorrente_id;
    end if;
    encerrada := true;
  end if;

  return jsonb_build_object('escopo',p_escopo,'apagados',n_del,'pagos_mantidos',n_pagos,'encerrada',encerrada);
end;
$fn$;

grant execute on function public.fin_fixa_aplicar(bigint,text,text,text,integer,integer,text,text) to authenticated;
grant execute on function public.fin_fixa_excluir(bigint,text) to authenticated;
grant execute on function public.fin_venc_do_mes(text,int) to authenticated;

notify pgrst, 'reload schema';
