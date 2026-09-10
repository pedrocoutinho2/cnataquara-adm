-- 005 · 10/09/2026 · ADM (cnataquara-financeiro, thelqaxsnuynevizhcla)
-- Aplicado via Supabase MCP. Decisao: 50-decisoes/2026-09-10-adm-comissao-matricula-folha-e-extra.md
-- A carga da equipe de Queimados (14 funcionarios + fichas) NAO esta aqui: tem dado
-- pessoal e este repo e publico. Vive so no banco.

-- DDL (migration fin_folha_comissao_extra_e_pagamentos)
alter table fin_folha add column if not exists comissao_extra_cents integer not null default 0;
alter table fin_folha add column if not exists pagamentos integer not null default 0;
comment on column fin_folha.comissao_extra_cents is 'Comissao extra por matricula, paga fora da folha: sem DSR, sem encargos, fora do PDF do contador. Entra no custo total. Decisao 10/09/2026.';
comment on column fin_folha.pagamentos is 'Quantidade de pagamentos recebidos no mes, base da comissao_tipo = pagamentos.';
notify pgrst, 'reload schema';

-- Comissao de matricula na folha = R$ 35 nas duas unidades
update fin_config set valor = valor || '{"valor_cents":3500,"nota":"Parte da comissao de matricula paga na folha (entra em comissao e gera DSR). A parte paga fora da folha fica em comissao_extra."}'::jsonb, updated_at=now()
 where chave='comissao_matricula' and unidade in ('taquara','queimados');

-- Comissao extra por matricula, fora da folha
insert into fin_config(unidade,chave,valor,descricao,updated_at) values
 ('taquara','comissao_extra','{"valor_cents":1500,"nota":"Por matricula, pago fora da folha. Sem DSR. Decisao 10/09/2026."}'::jsonb,'Comissao extra por matricula (fora da folha)',now()),
 ('queimados','comissao_extra','{"valor_cents":2783,"nota":"Por matricula, pago fora da folha. Sem DSR. Decisao 10/09/2026."}'::jsonb,'Comissao extra por matricula (fora da folha)',now());

-- Queimados alinhado com Taquara: provisoes (divisor 9 = ferias + terco, FGTS sobre provisoes) e lista de funcoes
update fin_config q set valor=t.valor, updated_at=now()
  from fin_config t
 where q.unidade='queimados' and q.chave='provisoes' and t.unidade='taquara' and t.chave='provisoes';
insert into fin_config(unidade,chave,valor,descricao,updated_at)
select 'queimados','funcoes',valor,descricao,now() from fin_config
 where unidade='taquara' and chave='funcoes'
   and not exists (select 1 from fin_config where unidade='queimados' and chave='funcoes');
