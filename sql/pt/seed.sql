
    ------------------------------------------- Comandos INSERT INTO ------------------------------------------------------------------

    ------------------------------------------------ [ARTISTA] ------------------------------------------------------------------------

    INSERT INTO artista (isni, nome, ano_inicio_atividade)
    VALUES (1234567890123456, 'John Lennon', 1956);

    INSERT INTO artista (isni, nome, ano_inicio_atividade)
    VALUES (2345678901234567, 'The Beatles', 1957);

    INSERT INTO artista (isni, nome, ano_inicio_atividade)
    VALUES (3456789012345678, 'Freddie Mercury', 1985);

    INSERT INTO artista (isni, nome, ano_inicio_atividade)
    VALUES (4567890123456789, 'Queen', 1970);

    INSERT INTO artista (isni, nome, ano_inicio_atividade)
    VALUES (9876543210987654, 'Elvis Presley', 1954);

    ------------------------------------------------ [SOLISTA] ------------------------------------------------------------------------

    INSERT INTO solista (isni)
    VALUES (1234567890123456);

    INSERT INTO solista (isni)
    VALUES (3456789012345678);

    INSERT INTO solista (isni)
    VALUES (9876543210987654);

    ------------------------------------------------ [GRUPO] --------------------------------------------------------------------------
    
    INSERT INTO grupo (isni)
    VALUES (2345678901234567);

    INSERT INTO grupo (isni)
    VALUES (4567890123456789);

    ------------------------------------------------ [MEMBRO] --------------------------------------------------------------------------

    INSERT INTO membro (isni_solista, isni_grupo)
    VALUES (1234567890123456, 2345678901234567);

    INSERT INTO membro (isni_solista, isni_grupo)
    VALUES (3456789012345678, 4567890123456789);

    ---------------------------------------------- [UTILIZADOR] ------------------------------------------------------------------------

    INSERT INTO utilizador (username, email, palavra_passe, data_nascimento)
    VALUES ('joaopedro', 'joaopedro@gmail.com', '1234', '12.02.2008');

    
    INSERT INTO utilizador (username, email, palavra_passe, data_nascimento)
    VALUES ('josemiguel', 'josemiguel@hotmail.com', '17312aVxaAE', '17.06.1992');

    ---------------------------------------------- [FAVORITO] --------------------------------------------------------------------------

    INSERT INTO favorito (username, isni)
    VALUES ('joaopedro', 1234567890123456);

    INSERT INTO favorito (username, isni)
    VALUES ('josemiguel', 4567890123456789);

    ----------------------------------------------- [ALBUM] -----------------------------------------------------------------------------

    INSERT INTO album (mbid, titulo, ano_lancamento, tipo, isni)
    VALUES ('12345678-1234-1234-1234-123456789012', 'Imagine', 1971, 'LP', 1234567890123456);

    INSERT INTO album (mbid, titulo, ano_lancamento, tipo, isni)
    VALUES ('11111111-1111-1111-1111-111111111111', 'Abbey Road', 1969, 'LP', 2345678901234567);

    --------------------------------------------- [SUPORTE_FISICO] -----------------------------------------------------------------------

    INSERT INTO suporte_fisico (tipo, mbid)
    VALUES ('Vinil', '12345678-1234-1234-1234-123456789012');

    INSERT INTO suporte_fisico (tipo, mbid)
    VALUES ('Cassete', '12345678-1234-1234-1234-123456789012');

    INSERT INTO suporte_fisico (tipo, mbid)
    VALUES ('CD', '11111111-1111-1111-1111-111111111111');

    ------------------------------------------------ [VERSAO] -----------------------------------------------------------------------------

    INSERT INTO versao (ean13, designacao, mbid, tipo)
    VALUES (1234567890123, 'Edição Deluxe', '12345678-1234-1234-1234-123456789012', 'Vinil');

    INSERT INTO versao (ean13, designacao, mbid, tipo)
    VALUES (1234567890124, 'Edição Standard', '12345678-1234-1234-1234-123456789012', 'Vinil');

    INSERT INTO versao (ean13, designacao, mbid, tipo)
    VALUES (1234567890125, 'Edição Deluxe', '12345678-1234-1234-1234-123456789012', 'Cassete');

    INSERT INTO versao (ean13, designacao, mbid, tipo)
    VALUES (1111111111111, 'Edição Deluxe', '11111111-1111-1111-1111-111111111111', 'CD');

    ------------------------------------------------ [POSSUI] -----------------------------------------------------------------------------
    
    INSERT INTO possui (username, ean13, data_adicao)
    VALUES ('joaopedro', 1234567890123, '12.12.2021');

    INSERT INTO possui (username, ean13, data_adicao)
    VALUES ('joaopedro', 1234567890125, '10.09.2024');

    INSERT INTO possui (username, ean13, data_adicao)
    VALUES ('josemiguel', 1111111111111, '21.05.2025');

    ------------------------------------------------ [LISTA_PERSONALIZADA] -----------------------------------------------------------------

    INSERT INTO lista_personalizada (username, nome)
    VALUES ('joaopedro', '80s');

    INSERT INTO lista_personalizada (username, nome)
    VALUES ('josemiguel', 'Nostalgia');

    ------------------------------------------------------ [REFERE] ------------------------------------------------------------------------

    INSERT INTO refere (username, nome, mbid)
    VALUES ('joaopedro', '80s', '12345678-1234-1234-1234-123456789012');

    INSERT INTO refere (username, nome, mbid)
    VALUES ('joaopedro', '80s', '11111111-1111-1111-1111-111111111111');

    INSERT INTO refere (username, nome, mbid)
    VALUES ('josemiguel', 'Nostalgia', '11111111-1111-1111-1111-111111111111');
