-- Rede (Taquara, Queimados, Jardim América). Gravar sem unidade não pode cair em 'taquara'. Aprovado por Pedro em 16/11/2026.
alter table public.fin_config               alter column unidade drop default;
alter table public.fin_lancamentos          alter column unidade drop default;
alter table public.fin_folha_config         alter column unidade drop default;
alter table public.fin_receitas             alter column unidade drop default;
alter table public.fin_df                   alter column unidade drop default;
alter table public.fin_recebiveis           alter column unidade drop default;
alter table public.fin_despesas_recorrentes alter column unidade drop default;
alter table public.fin_folha                alter column unidade drop default;
alter table public.fin_funcionarios         alter column unidade drop default;
alter table public.fin_ponto_espelho        alter column unidade drop default;
alter table public.fin_documentos           alter column unidade drop default;
alter table public.fin_parceiros            alter column unidade drop default;
alter table public.fin_contratos            alter column unidade drop default;
notify pgrst, 'reload schema';
