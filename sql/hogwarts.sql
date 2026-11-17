-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (ADS242N01)
-- Professor: Aguinaldo Neto
--
-- Aluno: Gabriel Aquino
-- Matrícula: 2021810
--
-- Escreva cada resposta logo abaixo do comentário da questão.
-- Comandos que a atividade pede para FALHAR devem ficar comentados,
-- seguidos do código/mensagem de erro e da sua explicação.
-- =====================================================================

SET SQL_SAFE_UPDATES = 0;

-- =====================================================================
-- 1. PREPARAÇÃO DO AMBIENTE (DDL)
-- =====================================================================
DROP DATABASE IF EXISTS hogwarts;
CREATE DATABASE hogwarts;
USE hogwarts;

-- Tabela casa
CREATE TABLE casa (
    id_casa   INT AUTO_INCREMENT,
    nome_casa VARCHAR(30) NOT NULL,
    fundador  VARCHAR(60),
    pontos    INT DEFAULT 0,
    CONSTRAINT pk_casa PRIMARY KEY (id_casa),
    CONSTRAINT uq_casa_nome UNIQUE (nome_casa)
);

-- Tabela professor
CREATE TABLE professor (
    id_prof          INT AUTO_INCREMENT,
    nome             VARCHAR(100) NOT NULL,
    salario          DECIMAL(10,2),
    data_contratacao DATE,
    id_casa          INT,
    CONSTRAINT pk_professor PRIMARY KEY (id_prof),
    CONSTRAINT ck_professor_salario CHECK (salario > 0),
    CONSTRAINT fk_professor_casa FOREIGN KEY (id_casa) REFERENCES casa (id_casa)
);

-- Tabela disciplina
CREATE TABLE disciplina (
    id_disc    INT AUTO_INCREMENT,
    nome_disc  VARCHAR(60) NOT NULL,
    ano_minimo INT,
    id_prof    INT,
    CONSTRAINT pk_disciplina PRIMARY KEY (id_disc),
    CONSTRAINT uq_disciplina_nome UNIQUE (nome_disc),
    CONSTRAINT ck_disciplina_ano CHECK (ano_minimo BETWEEN 1 AND 7),
    CONSTRAINT fk_disciplina_prof FOREIGN KEY (id_prof) REFERENCES professor (id_prof)
);

-- Tabela aluno
CREATE TABLE aluno (
    id_aluno      INT AUTO_INCREMENT,
    nome          VARCHAR(100) NOT NULL,
    ano_escolar   INT,
    id_casa       INT,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT pk_aluno PRIMARY KEY (id_aluno),
    CONSTRAINT ck_aluno_ano CHECK (ano_escolar BETWEEN 1 AND 7),
    CONSTRAINT ck_aluno_saldo CHECK (saldo_galeoes >= 0),
    CONSTRAINT fk_aluno_casa FOREIGN KEY (id_casa) REFERENCES casa (id_casa)
);

-- Tabela matricula
CREATE TABLE matricula (
    id_aluno INT,
    id_disc  INT,
    nota     DECIMAL(4,2),
    CONSTRAINT pk_matricula PRIMARY KEY (id_aluno, id_disc),
    CONSTRAINT ck_matricula_nota CHECK (nota BETWEEN 0 AND 10),
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    CONSTRAINT fk_matricula_disc FOREIGN KEY (id_disc) REFERENCES disciplina (id_disc)
);

-- Tabela registro_pontos
CREATE TABLE registro_pontos (
    id_registro   INT AUTO_INCREMENT,
    id_aluno      INT NOT NULL,
    id_prof       INT NOT NULL,
    pontos        INT NOT NULL,
    motivo        VARCHAR(150),
    data_registro DATE NOT NULL,
    CONSTRAINT pk_registro_pontos PRIMARY KEY (id_registro),
    CONSTRAINT fk_registro_aluno FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    CONSTRAINT fk_registro_prof FOREIGN KEY (id_prof) REFERENCES professor (id_prof)
);

-- Tabela produto
CREATE TABLE produto (
    id_produto   INT AUTO_INCREMENT,
    nome_produto VARCHAR(100) NOT NULL,
    loja         VARCHAR(50) NOT NULL,
    preco        DECIMAL(10,2),
    estoque      INT DEFAULT 0,
    CONSTRAINT pk_produto PRIMARY KEY (id_produto),
    CONSTRAINT ck_produto_preco CHECK (preco > 0),
    CONSTRAINT ck_produto_estoque CHECK (estoque >= 0)
);

-- Tabela compra
CREATE TABLE compra (
    id_compra   INT AUTO_INCREMENT,
    id_aluno    INT,
    id_produto  INT,
    quantidade  INT,
    valor_total DECIMAL(10,2),
    data_compra DATE NOT NULL,
    CONSTRAINT pk_compra PRIMARY KEY (id_compra),
    CONSTRAINT ck_compra_quantidade CHECK (quantidade > 0),
    CONSTRAINT fk_compra_aluno FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
    CONSTRAINT fk_compra_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
);

-- Tabela log_auditoria
CREATE TABLE log_auditoria (
    id_log    INT AUTO_INCREMENT,
    tabela    VARCHAR(30),
    operacao  VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_log_auditoria PRIMARY KEY (id_log)
);

-- Pergunta para pensar: por que matricula usa chave primária composta?
-- Resposta: porque uma matrícula é definida pela combinação de aluno e disciplina.
-- Com a chave composta (id_aluno, id_disc), o banco impede que o mesmo aluno seja
-- matriculado duas vezes na mesma disciplina. Se houvesse um id_matricula
-- auto_increment, esse id seria sempre diferente e nada impediria matrículas
-- repetidas para o mesmo aluno e a mesma disciplina, gerando dados duplicados
-- e notas conflitantes. Além disso, o id extra seria desnecessário, porque o
-- par já identifica cada linha.


-- =====================================================================
-- 1.1 CARGA INICIAL DE DADOS (DML)
-- =====================================================================
-- INSERT casa
INSERT INTO casa (nome_casa, fundador) VALUES
('Grifinória', 'Godric Gryffindor'), -- 1
('Sonserina',  'Salazar Slytherin'), -- 2
('Corvinal',   'Rowena Ravenclaw'),  -- 3
('Lufa-Lufa',  'Helga Hufflepuff');  -- 4

-- INSERT professor
INSERT INTO professor (nome, salario, data_contratacao, id_casa) VALUES
('Minerva McGonagall', 9500.00, '1956-12-01', 1),    -- 1
('Severo Snape',       8800.00, '1981-09-01', 2),    -- 2
('Fílio Flitwick',     8200.00, '1974-09-01', 3),    -- 3
('Pomona Sprout',      7900.00, '1972-09-01', 4),    -- 4
('Rúbeo Hagrid',       4500.00, '1993-09-01', NULL), -- 5
('Remo Lupin',         6200.00, '1993-09-01', NULL), -- 6
('Sibila Trelawney',   5100.00, '1980-09-01', NULL), -- 7
('Gilderoy Lockhart',  7000.00, '1992-09-01', NULL), -- 8
('Horácio Slughorn',   8000.00, '1996-09-01', NULL); -- 9

-- INSERT disciplina
INSERT INTO disciplina (nome_disc, ano_minimo, id_prof) VALUES
('Transfiguração', 1, 1),                      -- 1
('Poções', 1, 2),                              -- 2
('Feitiços', 1, 3),                            -- 3
('Herbologia', 1, 4),                          -- 4
('Trato das Criaturas Mágicas', 3, 5),         -- 5
('Defesa Contra as Artes das Trevas', 1, 6),   -- 6
('Adivinhação', 3, 7),                         -- 7
('Estudo dos Trouxas', 3, NULL),               -- 8
('Runas Antigas', 3, NULL);                    -- 9

-- INSERT aluno
INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes) VALUES
('Harry Potter',       5, 1, 120.00),  -- 1
('Hermione Granger',   5, 1,  85.00),  -- 2
('Rony Weasley',       5, 1,  12.00),  -- 3
('Neville Longbottom', 5, 1,  30.00),  -- 4
('Draco Malfoy',       5, 2, 500.00),  -- 5
('Pansy Parkinson',    5, 2, 150.00),  -- 6
('Vicente Crabbe',     5, 2,  40.00),  -- 7
('Luna Lovegood',      4, 3,  45.00),  -- 8
('Cho Chang',          6, 3, 200.00),  -- 9
('Padma Patil',        5, 3,  60.00),  -- 10
('Cedrico Diggory',    7, 4, 180.00),  -- 11
('Ana Abbott',         5, 4,  25.00),  -- 12
('Ernesto Macmillan',  5, 4,  70.00),  -- 13
('Teddy Lupin',        1, NULL, 0.00); -- 14 (ainda não passou pelo Chapéu Seletor)

-- INSERT matricula
INSERT INTO matricula (id_aluno, id_disc, nota) VALUES
(1,1,7.5),(1,2,5.0),(1,6,9.8),(1,5,8.0),
(2,1,10.0),(2,2,9.5),(2,3,10.0),(2,5,9.0),(2,9,9.5),
(3,1,6.0),(3,2,4.5),(3,7,5.5),
(4,2,3.0),(4,4,10.0),(4,6,7.0),
(5,2,9.0),(5,1,7.0),(5,5,4.0),
(6,2,7.5),(6,7,6.5),
(7,2,3.5),(7,6,2.0),
(8,5,8.5),(8,3,8.0),(8,4,9.0),
(9,3,8.5),(9,6,7.5),
(10,3,9.0),(10,7,6.0),
(11,4,8.5),(11,6,9.0),(11,1,8.0),
(12,4,8.0),
(13,4,7.0),(13,3,7.5);

-- INSERT produto
INSERT INTO produto (nome_produto, loja, preco, estoque) VALUES
('Varinha de Azevinho',              'Olivaras',             7.00,  10), -- 1
('Vassoura Nimbus 2001',             'Artigos de Quadribol', 300.00, 3), -- 2
('Sapo de Chocolate',                'Dedosdemel',           2.00,  200), -- 3
('Feijõezinhos de Todos os Sabores', 'Dedosdemel',           1.50,  150), -- 4
('Livro Monstruoso dos Monstros',    'Floreios e Borrões',   12.00, 20), -- 5
('Caldeirão de Estanho',             'Caldeirões Potage',    9.00,  0),  -- 6
('Kit de Logros',                    'Gemialidades Weasley', 25.00, 40), -- 7
('Pena de Repetição Rápida',         'Escribbulus',          15.00, 5);  -- 8

-- Confira: SELECT COUNT(*) de cada tabela
SELECT
    (SELECT COUNT(*) FROM casa)       AS casas,
    (SELECT COUNT(*) FROM professor)  AS professores,
    (SELECT COUNT(*) FROM disciplina) AS disciplinas,
    (SELECT COUNT(*) FROM aluno)      AS alunos,
    (SELECT COUNT(*) FROM matricula)  AS matriculas,
    (SELECT COUNT(*) FROM produto)    AS produtos;


-- =====================================================================
-- 2. MANUTENÇÃO PÓS-CARGA (ALTER E UPDATE)
-- =====================================================================
-- Questão 1
ALTER TABLE aluno ADD COLUMN email VARCHAR(100);
DESC aluno;

-- Questão 2
ALTER TABLE matricula ADD COLUMN situacao VARCHAR(20) DEFAULT 'Cursando';
DESC matricula;

-- Questão 3
ALTER TABLE produto ADD COLUMN ativo CHAR(1) DEFAULT 'S';
DESC produto;

-- Questão 4
ALTER TABLE casa MODIFY COLUMN fundador VARCHAR(100);
DESC casa;

-- Questão 5
ALTER TABLE professor RENAME COLUMN data_contratacao TO data_admissao;
DESC professor;

-- Questão 6
UPDATE aluno
SET email = CONCAT(LOWER(REPLACE(nome, ' ', '.')), '@hogwarts.edu');
SELECT id_aluno, nome, email FROM aluno;

-- Questão 7
ALTER TABLE aluno ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questão 8
UPDATE matricula
SET nota = LEAST(nota + 0.5, 10)
WHERE id_disc IN (SELECT id_disc
                  FROM disciplina
                  WHERE id_prof IN (SELECT id_prof FROM professor WHERE nome = 'Remo Lupin'));
-- Confira: Harry Potter deve ter 10.00 em Defesa Contra as Artes das Trevas (e não 10.30)
SELECT a.nome, d.nome_disc, m.nota
FROM matricula m
JOIN aluno a ON a.id_aluno = m.id_aluno
JOIN disciplina d ON d.id_disc = m.id_disc
WHERE a.nome = 'Harry Potter' AND d.nome_disc = 'Defesa Contra as Artes das Trevas';

-- Questão 9
UPDATE matricula
SET situacao = CASE WHEN nota >= 6 THEN 'Aprovado' ELSE 'Reprovado' END;
-- Confira: 7 matrículas reprovadas
SELECT COUNT(*) AS reprovadas FROM matricula WHERE situacao = 'Reprovado';

-- Questão 10
UPDATE professor
SET salario = salario * 1.10
WHERE id_casa IS NOT NULL AND data_admissao < '1980-01-01';
-- Confira: Minerva McGonagall deve ganhar 10450.00
SELECT nome, salario FROM professor WHERE nome = 'Minerva McGonagall';

-- Questão 11
UPDATE produto SET ativo = 'N' WHERE estoque = 0;

-- Questão 12
UPDATE produto SET preco = preco * 0.80 WHERE loja = 'Dedosdemel';
-- Confira: o Sapo de Chocolate deve custar 1.60
SELECT nome_produto, preco FROM produto WHERE nome_produto = 'Sapo de Chocolate';


-- =====================================================================
-- 3. REMOÇÃO DE DADOS (DELETE) E TESTES DE RESTRIÇÕES
-- =====================================================================
-- Questão 13
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails
--       (`hogwarts`.`aluno`, CONSTRAINT `fk_aluno_casa` FOREIGN KEY (`id_casa`) REFERENCES `casa` (`id_casa`))
-- Explicação: a Sonserina ainda tem alunos (e um professor, o Snape) apontando para ela pela chave
-- estrangeira. O banco não deixa apagar a linha "pai" enquanto existirem linhas "filhas" que dependem
-- dela, para não deixar alunos ligados a uma casa que não existe mais.

-- Questão 14
-- INSERT INTO aluno (nome, ano_escolar, id_casa) VALUES ('Dobby', 8, 1);
-- Erro: Error Code: 3819. Check constraint 'ck_aluno_ano' is violated.
-- Explicação: a restrição CHECK de ano_escolar só aceita valores de 1 a 7. Como o 8º ano está fora
-- dessa faixa, o banco recusa o INSERT antes de gravar a linha.

-- Questão 15
-- INSERT INTO aluno (nome, ano_escolar, id_casa, email) VALUES ('Harry Potter (Polissuco)', 5, 1, 'harry.potter@hogwarts.edu');
-- Erro: Error Code: 1062. Duplicate entry 'harry.potter@hogwarts.edu' for key 'aluno.uq_aluno_email'
-- Explicação: o e-mail 'harry.potter@hogwarts.edu' já pertence ao Harry Potter verdadeiro. A restrição
-- UNIQUE uq_aluno_email (criada na questão 7) não permite dois alunos com o mesmo e-mail.

-- Questão 16
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Erro: Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails
--       (`hogwarts`.`disciplina`, CONSTRAINT `fk_disciplina_prof` FOREIGN KEY (`id_prof`) REFERENCES `professor` (`id_prof`))
-- Explicação: o Snape é o professor de Poções: a linha dessa disciplina tem id_prof apontando para ele.
-- Apagar o professor deixaria a disciplina sem um professor que existe, então a chave estrangeira bloqueia.

-- Questão 17
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';
-- Explicação: este funciona porque o Lockhart não é referenciado por nenhuma outra tabela: não leciona
-- nenhuma disciplina e não registrou pontos. Sem linhas "filhas", não há chave estrangeira a violar.
-- O Snape, na questão 16, ainda era o professor de Poções.

-- Questão 18
-- Primeiro as matrículas (tabela filha), depois o aluno (tabela pai)
DELETE FROM matricula
WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');
DELETE FROM aluno WHERE nome = 'Vicente Crabbe';

-- Questão 19
DELETE FROM disciplina
WHERE id_disc NOT IN (SELECT id_disc FROM matricula);
-- Confira: 8 professores, 13 alunos, 8 disciplinas e 33 matrículas
SELECT (SELECT COUNT(*) FROM professor)  AS professores,
       (SELECT COUNT(*) FROM aluno)      AS alunos,
       (SELECT COUNT(*) FROM disciplina) AS disciplinas,
       (SELECT COUNT(*) FROM matricula)  AS matriculas;


-- =====================================================================
-- 4. TRIGGERS
-- =====================================================================
-- Questão 20 - trg_pontos_casa
DELIMITER $$
CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    UPDATE casa
    SET pontos = pontos + NEW.pontos
    WHERE id_casa = (SELECT id_casa FROM aluno WHERE id_aluno = NEW.id_aluno);
END$$
DELIMITER ;

-- Questão 21 - trg_valida_compra
DELIMITER $$
CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_estoque INT;
    DECLARE v_preco   DECIMAL(10,2);
    DECLARE v_saldo   DECIMAL(10,2);

    SELECT estoque, preco INTO v_estoque, v_preco
    FROM produto
    WHERE id_produto = NEW.id_produto;

    SELECT saldo_galeoes INTO v_saldo
    FROM aluno
    WHERE id_aluno = NEW.id_aluno;

    IF v_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estoque insuficiente no Beco Diagonal';
    END IF;

    IF v_saldo < v_preco * NEW.quantidade THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Galeões insuficientes no cofre do aluno';
    END IF;

    SET NEW.valor_total = v_preco * NEW.quantidade;
END$$
DELIMITER ;

-- Questão 22 - trg_baixa_compra
DELIMITER $$
CREATE TRIGGER trg_baixa_compra
AFTER INSERT ON compra
FOR EACH ROW
BEGIN
    UPDATE produto
    SET estoque = estoque - NEW.quantidade
    WHERE id_produto = NEW.id_produto;

    UPDATE aluno
    SET saldo_galeoes = saldo_galeoes - NEW.valor_total
    WHERE id_aluno = NEW.id_aluno;
END$$
DELIMITER ;

-- Questão 23 - trg_situacao_nota
DELIMITER $$
CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    IF NOT (NEW.nota <=> OLD.nota) THEN
        SET NEW.situacao = IF(NEW.nota >= 6, 'Aprovado', 'Reprovado');
    END IF;
END$$
DELIMITER ;

-- Questão 24 - trg_audita_salario
DELIMITER $$
CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO log_auditoria (tabela, operacao, descricao)
        VALUES ('professor', 'UPDATE',
                CONCAT(NEW.nome, ': salário de ', OLD.salario, ' para ', NEW.salario));
    END IF;
END$$
DELIMITER ;

-- Pergunta para pensar: por que a validação é BEFORE e a baixa é AFTER?
-- Resposta: a validação precisa rodar ANTES de a compra ser gravada: se o estoque ou o saldo não
-- bastarem, o SIGNAL cancela o INSERT e nada é gravado. O BEFORE também permite preencher
-- NEW.valor_total antes de a linha ir para a tabela. Já a baixa só faz sentido DEPOIS, quando a compra
-- já foi aceita e gravada: se fosse antes e o INSERT falhasse, o estoque e o saldo já teriam sido
-- alterados por uma compra que não existe.

-- Questão 25 - INSERT registro_pontos
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro) VALUES
( 2, 3,  20, 'Feitiço de levitação perfeito',         '2026-09-10'),
( 1, 2, -10, 'Atraso na aula de Poções',              '2026-09-12'),
( 5, 2,  15, 'Poção do Morto-Vivo impecável',         '2026-09-12'),
( 8, 5,  10, 'Cuidou de um testrálio ferido',         '2026-09-20'),
(11, 4,  25, 'Ajudou os alunos do 1º ano',            '2026-09-25'),
( 4, 4,  30, 'Identificou uma Mimbulus mimbletonia',  '2026-10-02'),
( 6, 1, -20, 'Fora da cama após o toque de recolher', '2026-10-05'),
( 1, 6,  50, 'Conjurou um Patrono corpóreo',          '2026-10-15'),
( 9, 3,  15, 'Duelo exemplar no Clube de Duelos',     '2026-10-18'),
( 5, 1, -30, 'Duelo proibido no corredor',            '2026-10-31'),
(10, 7,   5, 'Interpretação da bola de cristal',      '2026-11-03'),
(13, 4,  10, 'Colheita de mandrágoras',               '2026-11-05'),
( 3, 9,  10, 'Identificou um bezoar',                 '2026-11-06'),
( 8, 3,  20, 'Resposta brilhante sobre o Diadema',    '2026-11-08'),
( 6, 2,  25, 'Antídoto para venenos comuns',          '2026-11-09'),
( 5, 9,  40, 'Melhor poção do Clube do Slugue',       '2026-11-09');

-- Questão 25 - INSERT compra
-- valor_total não é informado: quem calcula é o trigger trg_valida_compra
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES
( 5, 2,  1, '2026-09-01'),
( 2, 5,  2, '2026-09-02'),
( 1, 3, 10, '2026-09-03'),
( 3, 4,  5, '2026-09-03'),
( 9, 8,  1, '2026-09-15'),
( 8, 5,  1, '2026-09-20'),
(11, 1,  1, '2026-10-01'),
( 6, 3, 20, '2026-10-10'),
( 1, 7,  2, '2026-10-20'),
(13, 4, 10, '2026-11-02');

-- Questão 25 - Rony tenta comprar a Nimbus
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (3, 2, 1, '2026-11-10');
-- Resultado: Error Code: 1644. Galeões insuficientes no cofre do aluno
-- Explicação: ainda há Nimbus em estoque (2), mas o Rony só tem 6.00 galeões e a vassoura custa 300.00.
-- O trigger BEFORE trg_valida_compra vê saldo < preço x quantidade e cancela a compra com o SIGNAL.

-- Questão 25 - Hermione tenta comprar o caldeirão
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (2, 6, 1, '2026-11-10');
-- Resultado: Error Code: 1644. Estoque insuficiente no Beco Diagonal
-- Explicação: a Hermione tem galeões de sobra, mas o Caldeirão de Estanho está com estoque 0. A
-- primeira validação do trigger (estoque < quantidade) já bloqueia a compra.

-- Questão 25 - Recuperação do Rony em Poções
-- Só a nota é alterada: quem recalcula a situação é o trigger trg_situacao_nota
UPDATE matricula SET nota = 6.5 WHERE id_aluno = 3 AND id_disc = 2;
-- Confira: a situação do Rony em Poções passou de Reprovado para Aprovado
SELECT id_aluno, id_disc, nota, situacao FROM matricula WHERE id_aluno = 3 AND id_disc = 2;

-- Questão 25 - Salário e data de admissão do Hagrid
UPDATE professor SET salario = 5000.00 WHERE nome = 'Rúbeo Hagrid';
UPDATE professor SET data_admissao = '1993-08-15' WHERE nome = 'Rúbeo Hagrid';
SELECT * FROM log_auditoria;
-- Linhas em log_auditoria: 1 (só a mudança de salário; a mudança da data de admissão não gera log,
-- porque o trigger só grava quando OLD.salario <> NEW.salario)
-- Por que o reajuste da questão 10 não aparece: o trigger trg_audita_salario só passou a existir na
-- seção 4, depois do UPDATE da questão 10. Trigger só age sobre comandos executados depois de criado.

-- Confira (seção 4): placar Grifinória 100, Corvinal 50, Lufa-Lufa 35, Sonserina 30
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;
-- Confira: Draco com 200.00 e Harry com 54.00; Nimbus com estoque 2; Sapo de Chocolate com 170
SELECT nome, saldo_galeoes FROM aluno WHERE nome IN ('Draco Malfoy', 'Harry Potter');
SELECT nome_produto, estoque FROM produto WHERE id_produto IN (2, 3);
-- Confira: soma de valor_total das compras = 474.00 e 1 linha em log_auditoria
SELECT SUM(valor_total) AS soma_valor_total FROM compra;
SELECT COUNT(*) AS linhas_log FROM log_auditoria;


-- =====================================================================
-- 5. CONTROLE DE TRANSAÇÕES (TCL)
-- =====================================================================
-- Questão 26
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50 WHERE nome = 'Draco Malfoy';
UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50 WHERE nome = 'Pansy Parkinson';
COMMIT;
-- Confira: Draco com 150.00 e Pansy com 168.00
SELECT nome, saldo_galeoes FROM aluno WHERE nome IN ('Draco Malfoy', 'Pansy Parkinson');

-- Questão 27
START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT nome_casa, pontos FROM casa;   -- placar zerado dentro da transação
ROLLBACK;
SELECT nome_casa, pontos FROM casa;   -- o placar voltou: o ROLLBACK desfez o UPDATE

-- Questão 28
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES (1, 1, 1, '2026-11-10');
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;    -- dentro da transação: 47.00
SELECT estoque FROM produto WHERE id_produto = 1;      -- dentro da transação: 8
ROLLBACK;
SELECT saldo_galeoes FROM aluno WHERE id_aluno = 1;    -- depois do ROLLBACK: 54.00
SELECT estoque FROM produto WHERE id_produto = 1;      -- depois do ROLLBACK: 9
-- O que aconteceu: os dois UPDATEs feitos pelo trigger trg_baixa_compra (estoque e saldo) fazem parte
-- da mesma transação do INSERT. Por isso o ROLLBACK desfez também as alterações do trigger.

-- Questão 29
START TRANSACTION;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');
SAVEPOINT sp_pontos_legitimos;
INSERT INTO registro_pontos (id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');
ROLLBACK TO SAVEPOINT sp_pontos_legitimos;
COMMIT;
-- Confira: Grifinória 100, Corvinal 50, Lufa-Lufa 50, Sonserina 30 e 17 linhas em registro_pontos
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;
SELECT COUNT(*) AS linhas_registro_pontos FROM registro_pontos;

-- Questão 30
SELECT @@autocommit;
-- Resposta: retorna 1, ou seja, o autocommit está ligado: cada comando é confirmado (COMMIT) sozinho
-- assim que é executado. Só dentro de um START TRANSACTION os comandos ficam pendentes até um COMMIT
-- ou ROLLBACK. Um CREATE TABLE no meio de uma transação aberta causa um COMMIT implícito: o MySQL
-- confirma tudo o que estava pendente antes de executar o comando DDL, e esse trabalho já não pode
-- mais ser desfeito com ROLLBACK.


-- =====================================================================
-- 6. DESAFIOS DE CONSULTA
-- =====================================================================
-- ---------- Nível 1: filtros e operadores especiais ----------

-- 6.1

-- 6.2

-- 6.3

-- 6.4

-- 6.5

-- 6.6

-- ---------- Nível 2: JOINs ----------

-- 6.7
-- Quantos alunos e por quê:

-- 6.8

-- 6.9

-- 6.10

-- 6.11

-- ---------- Nível 3: agrupamento e agregação ----------

-- 6.12

-- 6.13

-- 6.14

-- 6.15

-- 6.16

-- ---------- Nível 4: subconsultas ----------

-- 6.17

-- 6.18

-- 6.19

-- 6.20

-- 6.21
-- > ANY equivale a:

-- 6.22

-- 6.23

-- 6.24

-- ---------- Nível 5: UNION ALL ----------

-- 6.25

-- 6.26
-- Linhas com UNION ALL:
-- Linhas com UNION:
-- Explicação:

-- 6.27


-- =====================================================================
-- 7. VIEWS
-- =====================================================================
-- Questão 31

-- Questão 32

-- Questão 33

-- Questão 34

-- Questão 35

-- Questão 36

-- Questão 37
-- O que mudou e por quê:

-- Questão 38


-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL)
-- =====================================================================
-- Questão 39

-- Questão 40

-- Questão 41

-- Questão 42

-- Questão 43

-- Questão 44
-- Resultado de cada comando:

-- Questão 45
-- Como o trigger conseguiu atualizar a casa:

-- Questão 46

-- Questão 47
-- Vantagem dos papéis:

-- Questão 48

