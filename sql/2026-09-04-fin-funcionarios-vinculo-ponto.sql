-- 2026-09-04 · cnataquara-financeiro (thelqaxsnuynevizhcla)
-- Vinculo explicito entre a folha (projeto financeiro) e o cadastro do REP-A
-- (projeto ponto). Os bancos sao separados por exigencia fiscal (Portaria MTP
-- 671/2021), entao nao ha FK possivel: o vinculo e por uuid guardado aqui.
-- Casar por nome nao serve -- na folha e "Natany Rodrigues", no ponto e
-- "Natanny"; "Camila" contra "Camila Coutinho Santos"; e assim por diante.
alter table public.fin_funcionarios
  add column if not exists ponto_empregado_id uuid;

comment on column public.fin_funcionarios.ponto_empregado_id is
  'ponto.empregados.id no projeto snipevyvfxaotjhnabmx. Sem FK: bancos separados por isolamento fiscal (Portaria MTP 671/2021).';

create unique index if not exists fin_funcionarios_ponto_empregado_id_key
  on public.fin_funcionarios (ponto_empregado_id) where ponto_empregado_id is not null;

notify pgrst, 'reload schema';

-- Vinculos preenchidos em 04/09/2026. Mariana e Vandicleide ficaram de fora:
-- nao tem cadastro no REP-A. [CONFIRMAR] se "Natany Rodrigues" (folha) e a
-- mesma pessoa que "Natanny" (ponto) antes de fechar a competencia.
-- update public.fin_funcionarios set ponto_empregado_id = ... ;
