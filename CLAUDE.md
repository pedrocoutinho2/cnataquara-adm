# CLAUDE.md · cnataquara-adm

Instruções permanentes para sessões do Claude neste repo.

## O que é

Sistema administrativo do CNA Taquara. Cobre três unidades: Taquara,
Queimados e Jardim América. Equipe, documentos, contratos e parcerias, folha de
pagamento, despesas, receitas, DRE e projeções.

Já foi só "financeiro". Não é mais. O escopo hoje é administrativo, e o
financeiro é um dos módulos.

- Produção: https://adm.cnataquara.com.br
- Supabase: `thelqaxsnuynevizhcla` (tabelas `fin_*`)
- Nome do repo segue o padrão da unidade: `cnataquara-{subdomínio}`
- Unidades em `UNIDADES` (`index.html`): `taquara`, `queimados` e
  `jardim-america`. A tela de escolha de unidade é **gerada** dessa lista
  (`#unitBtns`), então acrescentar unidade é mexer só em `UNIDADES`

## Arquitetura

Monólito de arquivo único. `index.html` com HTML + CSS + JS vanilla inline,
sem build. **Dois blocos `<script>`**: o primeiro é o administrativo clássico
(vanilla, sem imports); o segundo é `type="module"` e carrega a gestão do ponto
eletrônico. São mundos separados de propósito, ver a seção do ponto abaixo.

Arquivos:

| Arquivo | O que é |
|---|---|
| `index.html` | Aplicação administrativa completa |
| `rep.html` | Legado. Versão avulsa da gestão do ponto, já portada para o `index.html`. Sem link no menu. Mantida só como rollback |
| `rep-entrar.html` | Legado. Login da versão avulsa |
| `CNAME` | `adm.cnataquara.com.br` |

Acesso a dados via REST direto, sem `supabase-js`:

```js
const SUPA = 'https://thelqaxsnuynevizhcla.supabase.co';
async function api(...)   // helper único de request
```

Tabelas: `fin_funcionarios`, `fin_func_ficha`, `fin_func_eventos`, `fin_folha`,
`fin_vales`, `fin_lancamentos`, `fin_despesas_recorrentes`, `fin_receitas`,
`fin_contratos`, `fin_parceiros`, `fin_documentos`, `fin_documento_tipos`,
`fin_usuarios`, `fin_config`, `fin_df`, `fin_ponto_espelho`.

RPCs de usuário: `fin_usuarios_listar`, `fin_usuario_criar`,
`fin_usuario_atualizar`, `fin_usuario_senha`, `fin_usuario_excluir`,
`fin_ativar_com_convite`, `fin_perfil_salvar`, `fin_perfil_trocar_senha`.

Storage: bucket `gestao-docs`, acesso por signed URL com expiração de 3600s.

## Atenção: o ponto eletrônico não fala com este banco

O menu tem a seção **Ponto eletrônico** com sete telas (equipe e biometria,
espelho, banco de horas, pendências, relatórios, terminais, configurações).
Elas moram no `index.html` mas apontam para o Supabase do ponto
(`snipevyvfxaotjhnabmx`, schema `ponto`), não para `thelqaxsnuynevizhcla`.

Não assuma que tudo neste repo é `fin_*`. O ponto eletrônico é
**arquiteturalmente isolado** por razão fiscal e legal, e essa separação de
banco é proposital. Ver `cnataquara-ponto`.

### Uma unidade, um REP

Multi-unidade desde 16/11/2026. Cada unidade do ADM é uma linha de `ponto.rep`
cuja coluna `unidade` casa com o id de `UNIDADES`. O módulo resolve o REP pela
unidade escolhida no ADM (`S.unidade` → `ponto.rep.unidade`) em
`garantirRep()`, e **nada no módulo usa `rep limit 1`**. Esse padrão foi
eliminado nas duas pontas: no front aqui e nas funções do banco, pela migration
`ponto_020_multi_unidade`.

O que decorre disso:

- Tudo que o módulo lê ou grava passa pelo REP da unidade escolhida: equipe,
  terminais, feriados, jornadas, banco de horas, pendências, relatórios e termo
  de biometria. Pessoa, terminal e feriado nascem nesse REP.
- Remover feriado só remove na unidade (`delete` com `eq('rep_id', REP)`).
- Trocar de unidade zera os caches (`EQUIPE`, `TURNOS`, `SITUACAO`, `TERMO`,
  `IDS`, `JORNADAS`).
- Unidade sem linha em `ponto.rep` (hoje Queimados) mostra aviso e não abre as
  telas do ponto.
- As RPCs que não recebem REP (`situacao_cadastro`, `relatorio_faltas`,
  `resumo_equipe`, `recorrencia_atrasos`, `listar_dispositivos`,
  `apuracao_competencia`) são filtradas no cliente por `daUnidade()`, que mantém
  só os `empregado_id` da unidade.

Como a convivência funciona:

- **HTML**: tudo dentro de `<div id="pontoWrap">`, irmão de `#view` dentro do
  `<main>`. O roteador mostra um ou outro, nunca os dois.
- **CSS**: o `cna.css` do repo `cnataquara-ponto` mais os estilos próprios das
  telas foram escopados sob `#pontoWrap` no bloco `<style id="pontoCSS">`.
  Oito classes colidiam com o administrativo (`.btn`, `.tag`, `.ok`, `.n`,
  `.num`, `.neg`, `.danger`) e o escopo resolve. Se atualizar o `cna.css` lá,
  reescope antes de trazer: nenhum seletor pode sair de `#pontoWrap`, com a
  única exceção de `body.dialogo-aberto`.
- **JS**: bloco `<script type="module">` no fim do body. O escopo de módulo
  isola tudo; a única superfície pública é `window.PONTO = { abrir, sair }`.
  O código usa delegação de evento, nunca `onclick` inline, e depende disso
  para funcionar dentro do módulo.
- **Views**: prefixo `rep_` (`rep_equipe`, `rep_espelho`, ...). O `render()`
  desvia para `window.PONTO.abrir(view.slice(4))` em vez de escrever no `#view`.
- **Sessão**: projetos Supabase diferentes significam usuários diferentes. O
  `doLogin()` do adm espelha as credenciais no projeto do ponto em segundo
  plano e deixa o resultado em `window.__PONTO_SESSAO`. Se a senha for outra,
  a própria tela pede uma vez (painel `p-repauth`). Falha no espelho nunca
  trava o login do adm.

A tela **Fechamento para a folha** (`view` `ponto`, tabela `fin_ponto_espelho`)
continua no banco financeiro e continua sendo digitada à mão. É a consolidação
que alimenta a folha, não o registro legal. Ligar o "Importar do REP-A" agora é
viável: os dois lados estão na mesma página.

## Regras de folha

- Marlon e Camila: Comercial, comissão de matrícula
- Sabrina: Coordenação, `coord_comercial` (50% do total de matrícula do Comercial)
- Natanny e Letícia: Administrativo, R$ 1,50 por pagamento
- Professores: sem comissão
- VT: 6% de desconto sobre salário + comissão (configurável)
- INSS: progressivo via função `fin_inss()`, recolhido à parte por guia
- Campo de adiantamento aparece na tabela e no PDF

Telas do administrativo não levam mascote.

## Deploy

Nunca entregue arquivo para upload manual. Sempre via API do GitHub.

1. Extraia o `<script>` com `re.findall`, salve em `/tmp/` e rode `node --check`
2. `GET` do arquivo para pegar o `sha`
3. `PUT` em `contents` com `sha` + conteúdo em base64
4. Poll em `pages/builds/latest` até `built` (~60 a 90s)
5. Confirme lendo via API com `Accept: application/vnd.github.raw`.
   A URL do Pages pode servir cache.

## Regras

- Busque o arquivo atual antes de editar. Nunca escreva de memória.
- Confirme com o Pedro antes de qualquer operação destrutiva no banco.
- Prefixo `fin_` nas tabelas é histórico e fica como está. Renomear tabela aqui
  significa reescrever as queries de um `index.html` de 146 KB, com risco em
  produção e ganho cosmético.
- Padrão visual compartilhado: ver `assets/PADRAO.md` no repo `cnataquara-ponto`.
