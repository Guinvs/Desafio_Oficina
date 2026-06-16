-- ============================================
-- ESQUEMA OFICINA MECÂNICA - MySQL Workbench
-- ============================================

CREATE DATABASE IF NOT EXISTS oficina;
USE oficina;

-- ============================================
-- TABELA: CLIENTE
-- ============================================
CREATE TABLE cliente (
    id_cliente INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    cpf_cnpj VARCHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(150),
    endereco VARCHAR(200),
    PRIMARY KEY (id_cliente)
);

-- ============================================
-- TABELA: VEICULO
-- ============================================
CREATE TABLE veiculo (
    id_veiculo INT NOT NULL AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    placa VARCHAR(8) NOT NULL UNIQUE,
    modelo VARCHAR(100) NOT NULL,
    marca VARCHAR(80) NOT NULL,
    ano_fabricacao YEAR,
    cor VARCHAR(30),
    PRIMARY KEY (id_veiculo),
    CONSTRAINT fk_veiculo_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente)
        ON DELETE RESTRICT
);

-- ============================================
-- TABELA: MECANICO
-- ============================================
CREATE TABLE mecanico (
    codigo_mecanico INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    endereco VARCHAR(200),
    especialidade VARCHAR(100) NOT NULL,
    PRIMARY KEY (codigo_mecanico)
);

-- ============================================
-- TABELA: EQUIPE
-- (necessária pois a narrativa fala em "equipe de mecânicos";
--  um agrupamento de mecânicos atende ao veículo e à OS)
-- ============================================
CREATE TABLE equipe (
    id_equipe INT NOT NULL AUTO_INCREMENT,
    nome_equipe VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_equipe)
);

-- ============================================
-- TABELA: EQUIPE_MECANICO (associativa N:N)
-- ============================================
CREATE TABLE equipe_mecanico (
    id_equipe INT NOT NULL,
    codigo_mecanico INT NOT NULL,
    PRIMARY KEY (id_equipe, codigo_mecanico),
    CONSTRAINT fk_equipemecanico_equipe
        FOREIGN KEY (id_equipe)
        REFERENCES equipe (id_equipe)
        ON DELETE CASCADE,
    CONSTRAINT fk_equipemecanico_mecanico
        FOREIGN KEY (codigo_mecanico)
        REFERENCES mecanico (codigo_mecanico)
        ON DELETE CASCADE
);

-- ============================================
-- TABELA: SERVICO
-- (tabela de referência de mão-de-obra)
-- ============================================
CREATE TABLE servico (
    id_servico INT NOT NULL AUTO_INCREMENT,
    descricao VARCHAR(150) NOT NULL,
    valor_mao_obra DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_servico)
);

-- ============================================
-- TABELA: PECA
-- ============================================
CREATE TABLE peca (
    id_peca INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    valor_unitario DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id_peca)
);

-- ============================================
-- TABELA: ORDEM_SERVICO
-- ============================================
CREATE TABLE ordem_servico (
    numero_os INT NOT NULL AUTO_INCREMENT,
    id_veiculo INT NOT NULL,
    id_equipe INT NOT NULL,
    data_emissao DATE NOT NULL,
    data_entrega_prevista DATE NOT NULL,
    data_conclusao DATE,
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0,
    status ENUM('ABERTA','AGUARDANDO_AUTORIZACAO','AUTORIZADA','EM_EXECUCAO','CONCLUIDA','CANCELADA') NOT NULL DEFAULT 'ABERTA',
    autorizado_cliente BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (numero_os),
    CONSTRAINT fk_os_veiculo
        FOREIGN KEY (id_veiculo)
        REFERENCES veiculo (id_veiculo)
        ON DELETE RESTRICT,
    CONSTRAINT fk_os_equipe
        FOREIGN KEY (id_equipe)
        REFERENCES equipe (id_equipe)
        ON DELETE RESTRICT
);

-- ============================================
-- TABELA: OS_SERVICO (associativa N:N)
-- serviços identificados/executados em cada OS
-- ============================================
CREATE TABLE os_servico (
    numero_os INT NOT NULL,
    id_servico INT NOT NULL,
    valor_cobrado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (numero_os, id_servico),
    CONSTRAINT fk_osservico_os
        FOREIGN KEY (numero_os)
        REFERENCES ordem_servico (numero_os)
        ON DELETE CASCADE,
    CONSTRAINT fk_osservico_servico
        FOREIGN KEY (id_servico)
        REFERENCES servico (id_servico)
        ON DELETE RESTRICT
);

-- ============================================
-- TABELA: OS_PECA (associativa N:N)
-- peças utilizadas em cada OS
-- ============================================
CREATE TABLE os_peca (
    numero_os INT NOT NULL,
    id_peca INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    valor_cobrado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (numero_os, id_peca),
    CONSTRAINT fk_ospeca_os
        FOREIGN KEY (numero_os)
        REFERENCES ordem_servico (numero_os)
        ON DELETE CASCADE,
    CONSTRAINT fk_ospeca_peca
        FOREIGN KEY (id_peca)
        REFERENCES peca (id_peca)
        ON DELETE RESTRICT
);
