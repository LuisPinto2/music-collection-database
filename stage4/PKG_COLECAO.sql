    -- -------------------------------------------------------------------------------------------------------------------------------
    -- Registar artistas
    -- -------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        pkg_colecao.regista_artista('0000000000000001', 'Dire Straits', 1977);
        pkg_colecao.regista_artista('0000000000000002', 'Day6', 2015);
        DBMS_OUTPUT.PUT_LINE('Artistas registados com sucesso.');
    END;
    /

    -- Tentativa de artista duplicado (-20005)
    BEGIN
        pkg_colecao.regista_artista('0000000000000001', 'Dire Straits', 1977);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM);     
    END;
    /

    -- -------------------------------------------------------------------------------------------------------------------------------
    -- Registar álbuns
    -- -------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        pkg_colecao.regista_album('1234567890123', 'Brothers in Arms', 'single', 1985, '0000000000000001', 'vinil');
        pkg_colecao.regista_album('9876543210987', 'The Book of Us', 'EP', 2019, '0000000000000002', 'CD', 'Versão Deluxe');
        DBMS_OUTPUT.PUT_LINE('Álbuns registados com sucesso.');
    END;
    /

    -- Tentativa de álbum com ano anterior ao início do artista (-20006)
    BEGIN
        pkg_colecao.regista_album('1111111111111', 'Invalid', 'Rock', 1970, '0000000000000001', 'CD');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM); 
    END;
    /

    -- -------------------------------------------------------------------------------------------------------------------------------
    -- Registar utilizadores
    -- -------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        pkg_colecao.regista_utilizador('usertest', 'usertest@gmail.com', 'pass123', 2000, '0000000000000001');
        DBMS_OUTPUT.PUT_LINE('Utilizador registado com sucesso.');
    END;
    /

    -- Tentativa de utilizador com menos de 13 anos (-20007)
    BEGIN
        pkg_colecao.regista_utilizador('user_jovem', 'jovem@gmail.com', 'password', 2015);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM); 
    END;
    /

    -- -------------------------------------------------------------------------------------------------------------------------------
    -- Registar posses
    -- -------------------------------------------------------------------------------------------------------------------------------
    DECLARE
        n_posses NUMBER;
    BEGIN
        n_posses := pkg_colecao.regista_posse('usertest', '1234567890123');
        DBMS_OUTPUT.PUT_LINE('Número de posses após 1º registo: ' || n_posses);

        n_posses := pkg_colecao.regista_posse('usertest', '9876543210987', TO_DATE('03.10.2020','DD.MM.YYYY'));
        DBMS_OUTPUT.PUT_LINE('Número de posses após 2º registo: ' || n_posses);
    END;
    /

    DECLARE
        n_posses NUMBER;
    -- Tentativa de posse antes do ano do álbum (-20008)
    BEGIN
        n_posses := pkg_colecao.regista_posse('usertest', '9876543210987', TO_DATE('2010-01-01','YYYY-MM-DD'));
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END;
    /

    -- -------------------------------------------------------------------------------------------------------------------------------
    -- Listar álbuns do utilizador
    -- -------------------------------------------------------------------------------------------------------------------------------
    DECLARE
        rc SYS_REFCURSOR;
        v_ean album.ean%TYPE;
        v_titulo album.titulo%TYPE;
        v_tipo album.tipo%TYPE;
        v_ano album.ano%TYPE;
        v_suporte album.suporte%TYPE;
        v_versao album.versao%TYPE;
        v_artista VARCHAR2(100);
    BEGIN
        rc := pkg_colecao.lista_albuns('usertest');
        LOOP
            FETCH rc INTO v_ean, v_titulo, v_tipo, v_ano, v_suporte, v_versao, v_artista;
            EXIT WHEN rc%NOTFOUND;

            -- Imprimir mensagem do tipo "Título do Álbum - Artista (Ano)"
            DBMS_OUTPUT.PUT_LINE(v_titulo || ' - ' || v_artista || ' (' || v_ano || ')');
        END LOOP;
        CLOSE rc;
    END;
    /

    -- -------------------------------------------------------------------------------------------------------------------------------
    -- Remover posse
    -- -------------------------------------------------------------------------------------------------------------------------------
    DECLARE
        n_posses NUMBER;
    BEGIN
        n_posses := pkg_colecao.remove_posse('usertest', '9876543210987');
        DBMS_OUTPUT.PUT_LINE('Número de posses após remoção: ' || n_posses);
    END;
    /

    DECLARE
        n_posses NUMBER;
    BEGIN
        -- Tentativa de remover uma posse inexistente (-20010)
        n_posses := pkg_colecao.remove_posse('usertest', '0000000000000');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END;
    /

    -- -------------------------------------------------------------------------------------------------------------------------------
    -- Remover utilizador
    -- -------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        pkg_colecao.remove_utilizador('usertest');
        DBMS_OUTPUT.PUT_LINE('Utilizador removido com sucesso.');
    END;
    /
    -- Tentativa de remover utilizador inexistente (-20004)
    BEGIN
        pkg_colecao.remove_utilizador('inexistentuser');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END;
    /
    -- -------------------------------------------------------------------------------------------------------------------------------
    -- Remover álbuns
    -- -------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        pkg_colecao.remove_album('1234567890123');
        pkg_colecao.remove_album('9876543210987');
        DBMS_OUTPUT.PUT_LINE('Álbuns removidos com sucesso.');
    END;
    /

    -- Tentativa de remover álbum inexistente (-20003)
    BEGIN
        pkg_colecao.remove_album('0000000000000');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END;
    /
    -- -------------------------------------------------------------------------------------------------------------------------------
    -- Remover artistas
    -- -------------------------------------------------------------------------------------------------------------------------------
    BEGIN
        pkg_colecao.remove_artista('0000000000000001');
        pkg_colecao.remove_artista('0000000000000002');
        DBMS_OUTPUT.PUT_LINE('Artistas removidos com sucesso.');
    END;
    /

    -- Tentativa de remover artista inexistente (-20002)
    BEGIN
        pkg_colecao.remove_artista('0000000000000000');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END;
    /