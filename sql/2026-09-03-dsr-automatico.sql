-- 2026-09-03 · DSR: dias úteis e dias de descanso passam a ser calculados
-- automaticamente pelo calendário do mês (domingos + feriados), no front.
-- Esvaziar as chaves em fin_config é o que liga o automático: o front só
-- respeita valor manual quando a chave existe e não está vazia.
-- Queimados fica explicitamente manual, porque a lista de feriados embutida
-- no front é a do município do Rio de Janeiro. [CONFIRMAR] feriados de Queimados.

update fin_config
   set valor = jsonb_build_object(
         'nota','dias_uteis e dias_descanso vazios = calculo automatico pelo calendario do mes (domingos + feriados). Preencher congela.'),
       updated_at = now()
 where unidade = 'taquara' and chave = 'dsr';

update fin_config
   set valor = jsonb_build_object(
         'dias_uteis', 26,
         'dias_descanso', 5,
         'nota','Queimados segue manual: a lista de feriados municipais embutida no front e a do Rio capital.'),
       updated_at = now()
 where unidade = 'queimados' and chave = 'dsr';

notify pgrst, 'reload schema';
