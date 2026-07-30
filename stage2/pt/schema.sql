    ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY';
    
    ----------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------- Comandos DROP TABLE ------------------------------------------------------------------

    DROP TABLE refere;
    DROP TABLE possui;
    DROP TABLE versao;
    DROP TABLE suporte_fisico;
    DROP TABLE album;
    DROP TABLE lista_personalizada;
    DROP TABLE favorito;
    DROP TABLE membro;
    DROP TABLE solista;
    DROP TABLE grupo;
    DROP TABLE utilizador;
    DROP TABLE artista;

    ----------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------- Comandos CREATE TABLE -----------------------------------------------------------------

    CREATE TABLE artista (
        isni                 NUMBER(16),
        nome                 VARCHAR(40) CONSTRAINT nn_artista_nome       NOT NULL,
        ano_inicio_atividade NUMBER(4)   CONSTRAINT nn_artista_ano_inicio NOT NULL,
        --
        CONSTRAINT pk_artista
            PRIMARY KEY (isni),
        --
        CONSTRAINT ck_artista_isni_len                                              -- RIA-07
            CHECK (isni >= 1000000000000000 AND isni <= 9999999999999999)
    );

    ----------------------------------------------------------------------------------------------------------------------------------
    
    CREATE TABLE solista (
        isni NUMBER(16),
        --
        CONSTRAINT pk_solista
            PRIMARY KEY (isni),
        --
        CONSTRAINT fk_solista_artista                                              -- RIA-10: solista COVER artista
            FOREIGN KEY (isni) 
            REFERENCES artista(isni)
    );

    ----------------------------------------------------------------------------------------------------------------------------------

    CREATE TABLE grupo (
        isni NUMBER(16),
        --
        CONSTRAINT pk_grupo
            PRIMARY KEY (isni),
        --
        CONSTRAINT fk_grupo_artista                                               -- RIA-10: grupo COVER artista
            FOREIGN KEY (isni) 
            REFERENCES artista(isni)
    );

    ----------------------------------------------------------------------------------------------------------------------------------

    CREATE TABLE membro (
        isni_solista NUMBER(16),
        isni_grupo   NUMBER(16),
        --
        CONSTRAINT pk_membro
            PRIMARY KEY (isni_solista, isni_grupo),
        --
        CONSTRAINT fk_membro_solista 
            FOREIGN KEY (isni_solista) 
            REFERENCES solista(isni),
        --
        CONSTRAINT fk_membro_grupo 
            FOREIGN KEY (isni_grupo) 
            REFERENCES grupo(isni)
    );

    ----------------------------------------------------------------------------------------------------------------------------------

    CREATE TABLE utilizador (
        username        VARCHAR(25),
        email           VARCHAR(40) CONSTRAINT nn_utilizador_email           NOT NULL,
        palavra_passe   VARCHAR(40) CONSTRAINT nn_utilizador_palavra_passe   NOT NULL,
        data_nascimento DATE         CONSTRAINT nn_utilizador_data_nascimento NOT NULL,
        --
        CONSTRAINT pk_utilizador
            PRIMARY KEY (username),
        --
        CONSTRAINT uq_user_email                            -- RIA-13
            UNIQUE(email),
        --
        CONSTRAINT ck_user_username                         -- RIA-14
            CHECK(REGEXP_LIKE(username,'^[A-Za-z0-9]+$')),
        --
        CONSTRAINT ck_user_idade                            -- RIA-15 (Com limitações, não é dinâmica)
            CHECK (data_nascimento <= DATE '2012-11-07')
    );

    ----------------------------------------------------------------------------------------------------------------------------------

    CREATE TABLE favorito (
        username VARCHAR(25) CONSTRAINT nn_favorito_username NOT NULL,
        isni     NUMBER(16)  CONSTRAINT nn_favorito_isni     NOT NULL,
        --
        CONSTRAINT pk_favorito 
            PRIMARY KEY (username),
        --
        CONSTRAINT fk_favorito_user 
            FOREIGN KEY (username) 
            REFERENCES utilizador(username),
        --
        CONSTRAINT fk_favorito_artista 
            FOREIGN KEY (isni) 
            REFERENCES artista(isni)
    );

    ----------------------------------------------------------------------------------------------------------------------------------

    CREATE TABLE lista_personalizada (
        username VARCHAR(25) CONSTRAINT nn_lista_pers_username NOT NULL,
        nome     VARCHAR(40) CONSTRAINT nn_lista_pers_nome     NOT NULL,
        --
        CONSTRAINT pk_lista_personalizada 
            PRIMARY KEY (username, nome),
        --
        CONSTRAINT fk_lista_user 
            FOREIGN KEY (username) 
            REFERENCES utilizador(username) 
            ON DELETE CASCADE
    );

    ----------------------------------------------------------------------------------------------------------------------------------

    CREATE TABLE album(
        mbid           VARCHAR(36),
        titulo         VARCHAR(40) CONSTRAINT nn_album_titulo         NOT NULL,
        ano_lancamento NUMBER(4)    CONSTRAINT nn_album_ano_lancamento NOT NULL,
        tipo           VARCHAR(10)  CONSTRAINT nn_album_tipo           NOT NULL,
        isni           NUMBER(16)   CONSTRAINT nn_album_isni           NOT NULL,
        --
        CONSTRAINT pk_album
            PRIMARY KEY (mbid),
        --
        CONSTRAINT ck_album_mbid_pos                    -- RIA-01
            CHECK (LENGTH(mbid) = 36),
        --
        CONSTRAINT ck_album_tipo                        -- RIA-02
            CHECK(LOWER(tipo) IN ('single', 'ep', 'lp')),
        --
        CONSTRAINT ck_album_ano_pos 
            CHECK (ano_lancamento > 0),
        --
        CONSTRAINT fk_album_artista
            FOREIGN KEY (isni) 
            REFERENCES artista(isni)
    );

    ----------------------------------------------------------------------------------------------------------------------------------
    
    CREATE TABLE suporte_fisico(
        tipo VARCHAR(10) CONSTRAINT nn_suporte_fisico_tipo NOT NULL,
        mbid VARCHAR(36) CONSTRAINT nn_suporte_fisico_mbid NOT NULL,
        --
        CONSTRAINT pk_suporte_fisico
            PRIMARY KEY (mbid, tipo),
        --
        CONSTRAINT fk_suporte_album
            FOREIGN KEY (mbid)
            REFERENCES album(mbid)
            ON DELETE CASCADE,
        --
        CONSTRAINT ck_suporte_tipo                      -- RIA-11
            CHECK (LOWER(tipo) IN('cd', 'vinil', 'cassete'))
    );

    ----------------------------------------------------------------------------------------------------------------------------------

    CREATE TABLE versao (
        ean13      NUMBER(13),
        designacao VARCHAR(40) CONSTRAINT nn_versao_designacao NOT NULL,
        mbid       VARCHAR(36) CONSTRAINT nn_versao_mbid       NOT NULL,
        tipo       VARCHAR(10) CONSTRAINT nn_versao_tipo       NOT NULL,
        --
        CONSTRAINT pk_versao
            PRIMARY KEY (ean13),
        --
        CONSTRAINT fk_versao_album 
            FOREIGN KEY (mbid) 
            REFERENCES album(mbid),
        --
        CONSTRAINT fk_versao_suporte 
            FOREIGN KEY (mbid, tipo)
            REFERENCES suporte_fisico(mbid, tipo),
        --
        CONSTRAINT ck_ean13_pos                             -- RIA-12
            CHECK (ean13 >= 1000000000000 AND ean13 <= 9999999999999)
    );

    ----------------------------------------------------------------------------------------------------------------------------------

    CREATE TABLE possui (
        username    VARCHAR(25) CONSTRAINT nn_possui_username    NOT NULL,
        ean13       NUMBER(13)  CONSTRAINT nn_possui_ean13       NOT NULL,
        data_adicao DATE        CONSTRAINT nn_possui_data_adicao NOT NULL,
        --
        CONSTRAINT pk_possui 
            PRIMARY KEY (username, ean13),
        --
        CONSTRAINT fk_possui_user FOREIGN KEY (username)
            REFERENCES utilizador(username)
            ON DELETE CASCADE,
        --
        CONSTRAINT fk_possui_versao FOREIGN KEY (ean13)
            REFERENCES versao(ean13)
            ON DELETE CASCADE
    );

    ----------------------------------------------------------------------------------------------------------------------------------
    
    CREATE TABLE refere (
        username VARCHAR(25) CONSTRAINT nn_refere_username NOT NULL,
        nome     VARCHAR(40) CONSTRAINT nn_refere_nome     NOT NULL,
        mbid     VARCHAR(36) CONSTRAINT nn_refere_mbid     NOT NULL,
        --
        CONSTRAINT pk_refere 
            PRIMARY KEY (username, nome, mbid),
        --
        CONSTRAINT fk_refere_lista 
            FOREIGN KEY (username, nome) 
            REFERENCES lista_personalizada(username, nome) 
            ON DELETE CASCADE,
        --
        CONSTRAINT fk_refere_album 
            FOREIGN KEY (mbid) 
            REFERENCES album(mbid) 
            ON DELETE CASCADE
    );

    ----------------------------------------------------------------------------------------------------------------------------------
    -- Restrições de Integridade Adicional não suportadas:
        -- RIA-03: As faixas de um álbum vão do número de ordem 1 em diante.
        -- RIA-04: O código ISRC de uma canção tem de ter 12 carateres.
        -- RIA-05: A duração de uma canção tem de ser positiva.
        -- RIA-06: Caso um álbum seja interpretado por um artista, esse artista tem de interpretar todas as canções desse álbum.
        -- RIA-08: O ano de lançamento de um álbum interpretado por um artista tem de ser posterior ou igual ao ano de início de atividade desse artista.
        -- RIA-09: O ano de lançamento de um álbum tem de ser posterior ou igual ao ano de início de atividade de todos os artistas que interpretam as canções nas faixas desse álbum.
        -- RIA-15: A data de nascimento de um utilizador tem de ser 13 ou mais anos anterior à data atual, bastando fazer a verificação aquando de criação da sua conta no sistema de 
        --         informação. (Implementada de modo não dinâmico)
        -- RIA-16: O ano da data de adição de uma versão de álbum à coleção de um utilizador tem de ser posterior ou igual ao ano de lançamento do álbum.
        -- RIA-17: A data de adição de uma versão de álbum à coleção de um utilizador tem de ser posterior ou igual à data em que o utilizador perfez 13 anos.
        -- RIA-18: A prioridade com que um utilizador deseja uma versão de um álbum tem de ser alta, média, ou baixa.
    ----------------------------------------------------------------------------------------------------------------------------------
