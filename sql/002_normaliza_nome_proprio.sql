-- 2026-09-02 · normalizacao de nome proprio (capNome)
-- Backups: fin_funcionarios_bkp_20260902_cap, fin_func_ficha_bkp_20260902_cap
-- Projeto: thelqaxsnuynevizhcla (cnataquara-financeiro)

update fin_funcionarios set nome='Pedro (Professor)' where id=16;  -- Pedro (professor)
update fin_funcionarios set nome='Mariana de Moraes' where id=18;  -- mariana de moraes
update fin_func_ficha set bairro='Guaratiba' where funcionario_id=1;  -- GUARATIBA
update fin_func_ficha set bairro='Jacarepagua' where funcionario_id=4;  -- JACAREPAGUA
update fin_func_ficha set bairro='Guaratiba' where funcionario_id=5;  -- GUARATIBA
update fin_func_ficha set bairro='Pedra de Guaratiba' where funcionario_id=6;  -- PEDRA DE GUARATIBA
update fin_func_ficha set bairro='Taquara' where funcionario_id=8;  -- TAQUARA
update fin_func_ficha set bairro='Taquara' where funcionario_id=10;  -- TAQUARA
update fin_func_ficha set bairro='Praça Seca' where funcionario_id=12;  -- PRAÇA SECA
update fin_func_ficha set bairro='Anil' where funcionario_id=13;  -- ANIL
update fin_func_ficha set bairro='Taquara' where funcionario_id=14;  -- TAQUARA
update fin_func_ficha set bairro='Cascadura' where funcionario_id=16;  -- CASCADURA
update fin_func_ficha set bairro='Taquara' where funcionario_id=17;  -- TAQUARA
update fin_func_ficha set bairro='Taquara' where funcionario_id=18;  -- TAQUARA
update fin_func_ficha set cargo_ctps='Inst. de Ensino' where funcionario_id=8;  -- INST.DE ENSINO
update fin_func_ficha set complemento='Lote 8 Quadra 154' where funcionario_id=1;  -- LOTE 8 QUADRA 154
update fin_func_ficha set complemento='Casa 01' where funcionario_id=5;  -- CASA 01
update fin_func_ficha set complemento='Bl01 Apt 504' where funcionario_id=9;  -- BL01 APT 504
update fin_func_ficha set complemento='Bl 06 Ap 404' where funcionario_id=10;  -- BL 06 AP 404
update fin_func_ficha set complemento='Ap 101/102' where funcionario_id=12;  -- AP 101/102
update fin_func_ficha set complemento='Casa 4' where funcionario_id=13;  -- CASA 4
update fin_func_ficha set complemento='Casa 2' where funcionario_id=14;  -- CASA 2
update fin_func_ficha set logradouro='Rua Horacio Macedo' where funcionario_id=1;  -- RUA HORACIO MACEDO
update fin_func_ficha set logradouro='Rua Sossego' where funcionario_id=4;  -- RUA SOSSEGO
update fin_func_ficha set logradouro='Rua Sussi' where funcionario_id=5;  -- RUA SUSSI
update fin_func_ficha set logradouro='Rua Mauricio Loppert da Silva' where funcionario_id=6;  -- RUA MAURICIO LOPPERT DA SILVA
update fin_func_ficha set logradouro='Rua Apeibe' where funcionario_id=8;  -- RUA APEIBE
update fin_func_ficha set logradouro='Av. Conego de Vasconcelos' where funcionario_id=9;  -- AV.CONEGO DE VASCONCELOS
update fin_func_ficha set logradouro='Av. dos Mananciais' where funcionario_id=10;  -- AV.DOS MANANCIAIS
update fin_func_ficha set logradouro='Rua Baronesa' where funcionario_id=12;  -- RUA BARONESA
update fin_func_ficha set logradouro='Est. de Jarepuagua' where funcionario_id=13;  -- EST.DE JAREPUAGUA
update fin_func_ficha set logradouro='Rua Cortes' where funcionario_id=14;  -- RUA CORTES
update fin_func_ficha set logradouro='Trav. Felicio' where funcionario_id=16;  -- TRAV.FELICIO
update fin_func_ficha set logradouro='Rua Adalgisa Neri' where funcionario_id=17;  -- RUA ADALGISA NERI
update fin_func_ficha set logradouro='Rua Professor Alpheu Portella' where funcionario_id=18;  -- RUA PROFESSOR ALPHEU PORTELLA
update fin_func_ficha set nome_mae='Andreza Ribeiro Dantas' where funcionario_id=1;  -- ANDREZA RIBEIRO DANTAS
update fin_func_ficha set nome_mae='Maria Diva Donascimento' where funcionario_id=4;  -- MARIA DIVA DONASCIMENTO
update fin_func_ficha set nome_mae='Andrea Maciel da Silva' where funcionario_id=5;  -- ANDREA MACIEL DA SILVA
update fin_func_ficha set nome_mae='Elizabete da Conceição de Carvalho' where funcionario_id=6;  -- ELIZABETE DA CONCEIÇÃO DE CARVALHO
update fin_func_ficha set nome_mae='Denise Rocha Paes' where funcionario_id=8;  -- DENISE ROCHA PAES
update fin_func_ficha set nome_mae='Fabiola Nunes Cardoso Pinheiro' where funcionario_id=9;  -- FABIOLA NUNES CARDOSO PINHEIRO
update fin_func_ficha set nome_mae='Geysa Azevedo Muller' where funcionario_id=10;  -- GEYSA AZEVEDO MULLER
update fin_func_ficha set nome_mae='Rosangela Maria Ximenes da Fonseca' where funcionario_id=12;  -- ROSANGELA MARIA XIMENES DA FONSECA
update fin_func_ficha set nome_mae='Danielle Borneo Denys Cattete' where funcionario_id=13;  -- DANIELLE BORNEO DENYS CATTETE
update fin_func_ficha set nome_mae='Rozelia Ferreira Figueredo' where funcionario_id=14;  -- ROZELIA FERREIRA FIGUEREDO
update fin_func_ficha set nome_mae='Heloisa Helena Lopes dos Santos' where funcionario_id=16;  -- HELOISA HELENA LOPES DOS SANTOS
update fin_func_ficha set nome_mae='Elaine Aparecida Amancio de Almeida Inacio' where funcionario_id=17;  -- ELAINE APARECIDA AMANCIO DE ALMEIDA INACIO
update fin_func_ficha set nome_mae='Maria da Paz Jacob de Moraes' where funcionario_id=18;  -- MARIA DA PAZ JACOB DE MORAES
-- ---- projeto do ponto: snipevyvfxaotjhnabmx ----
-- Backup: ponto.empregados_bkp_20260902_cap
update ponto.empregados set nome='Camila Coutinho Santos' where id='3bbd5b03-8800-451c-b1ff-d815301c45dc';  -- CAMILA COUTINHO SANTOS
update ponto.empregados set nome='Letícia Ribeiro' where id='a5064689-7102-4c3a-bf3f-1edac7cfb08a';  -- LETÍCIA RIBEIRO
update ponto.empregados set nome='Marlon de Carvalho Antunes' where id='1f718090-e05d-4c7a-ab2c-d90a71a73ea8';  -- MARLON DE CARVALHO ANTUNES
update ponto.empregados set nome='Natanny' where id='f229741b-cc5e-4793-a152-d3b5d6a622da';  -- NATANNY
update ponto.empregados set nome='Pedro Coutinho' where id='664a93c2-084c-4397-9e74-b5d437e059b6';  -- PEDRO COUTINHO
update ponto.empregados set cargo='Consultor Comercial' where id='3bbd5b03-8800-451c-b1ff-d815301c45dc';  -- Consultor comercial
update ponto.empregados set cargo='Consultor Comercial' where id='1f718090-e05d-4c7a-ab2c-d90a71a73ea8';  -- Consultor comercial