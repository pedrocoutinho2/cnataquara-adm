-- 002 · 2026-09-08 · CNA ADM
-- Nome de despesa e responsavel nunca ficam todos em caixa baixa.
-- Preserva sigla ja digitada em caixa alta (IPTU, SIMPLES, PJ, TikTok),
-- mantem conectivo interno minusculo e aplica grafia canonica de siglas conhecidas.

create or replace function public.fin_cap_titulo(p text)
returns text
language plpgsql
immutable
set search_path = public
as $fn$
declare
  minus text[] := array['de','da','das','do','dos','e','em','na','no','nas','nos',
                        'a','o','as','os','ao','aos','à','às','com','para','por',
                        'sem','sob','sobre','ou','del','la','le','les','van','von','y'];
  siglas jsonb := '{"cna":"CNA","fgts":"FGTS","inss":"INSS","iptu":"IPTU","ipva":"IPVA",
                    "darf":"DARF","gps":"GPS","pj":"PJ","pf":"PF","cnpj":"CNPJ","cpf":"CPF",
                    "ssd":"SSD","hd":"HD","tv":"TV","wifi":"WiFi","ifood":"iFood","tim":"TIM",
                    "vivo":"Vivo","oi":"Oi","dae":"DAE","dre":"DRE","df":"DF","vt":"VT",
                    "va":"VA","vr":"VR","rep":"REP","crm":"CRM","adm":"ADM"}'::jsonb;
  t text; palavra text; base text; canon text; m text[]; res text[] := '{}'; i int := 0;
begin
  t := btrim(regexp_replace(coalesce(p,''), '\s+', ' ', 'g'));
  if t = '' then return nullif(t,''); end if;
  foreach palavra in array string_to_array(t, ' ') loop
    i := i + 1;
    base := lower(regexp_replace(palavra, '[^[:alpha:]]', '', 'g'));
    canon := siglas ->> base;
    if canon is not null then
      res := res || regexp_replace(palavra, '[[:alpha:]]+', canon);
    elsif palavra <> lower(palavra) then
      res := res || palavra;
    elsif i > 1 and base = any(minus) then
      res := res || palavra;
    else
      m := regexp_match(palavra, '^([^[:alpha:]]*)([[:alpha:]])(.*)$');
      if m is null then res := res || palavra;
      else res := res || (m[1] || upper(m[2]) || m[3]);
      end if;
    end if;
  end loop;
  return array_to_string(res, ' ');
end;
$fn$;

comment on function public.fin_cap_titulo(text) is
  'Title case defensivo para nomes de despesa e responsavel: capitaliza palavras totalmente minusculas, preserva siglas e conectivos.';

create or replace function public.fin_tg_cap_nomes()
returns trigger
language plpgsql
set search_path = public
as $fn$
begin
  new.nome := fin_cap_titulo(new.nome);
  if new.responsavel is not null then
    new.responsavel := fin_cap_titulo(new.responsavel);
  end if;
  return new;
end;
$fn$;

drop trigger if exists trg_cap_nomes on public.fin_lancamentos;
create trigger trg_cap_nomes
  before insert or update of nome, responsavel on public.fin_lancamentos
  for each row execute function public.fin_tg_cap_nomes();

drop trigger if exists trg_cap_nomes on public.fin_despesas_recorrentes;
create trigger trg_cap_nomes
  before insert or update of nome, responsavel on public.fin_despesas_recorrentes
  for each row execute function public.fin_tg_cap_nomes();

-- backfill (executado em 2026-09-08: 78 lancamentos + 2 recorrentes)
update fin_lancamentos set nome = nome
 where nome <> fin_cap_titulo(nome)
    or (responsavel is not null and responsavel <> fin_cap_titulo(responsavel));
update fin_despesas_recorrentes set nome = nome
 where nome <> fin_cap_titulo(nome)
    or (responsavel is not null and responsavel <> fin_cap_titulo(responsavel));

notify pgrst, 'reload schema';
