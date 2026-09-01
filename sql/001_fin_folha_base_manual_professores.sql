-- 2026-09-01 · fin_folha.base_manual_cents
--
-- Na folha, professores (tipo = 'horista') passam a ter o VALOR DO MES como
-- dado digitado. As horas deixam de ser entrada e viram derivada:
--   horas = base_manual_cents / fin_funcionarios.valor_hora_cents
--
-- Motivo: os valores/hora praticados nao sao redondos (R$ 32,76 / 34,39 /
-- 36,03). Guardando as horas como dado primario, qualquer arredondamento
-- deslocava centavos no valor pago. Guardando o valor, o que a escola paga
-- fica exato e as horas ficam aproximadas, que e a ordem certa.
--
-- Compatibilidade: quando base_manual_cents e NULL, o calculo antigo
-- (horas x valor_hora_cents) continua valendo. Nao houve backfill porque nao
-- havia nenhuma linha de fin_folha para horista na data da migracao.
--
-- Aplicada em producao via apply_migration em 2026-09-01.

alter table public.fin_folha
  add column if not exists base_manual_cents integer;

comment on column public.fin_folha.base_manual_cents is
  'Valor do mes digitado direto para horista (professores). Quando preenchido e a base do calculo; a coluna horas passa a ser derivada (base / valor_hora_cents) e serve apenas para exibicao e relatorio. Quando nulo, mantem o comportamento antigo: base = horas * valor_hora_cents.';

notify pgrst, 'reload schema';
