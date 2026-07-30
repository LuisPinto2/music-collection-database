    CREATE OR REPLACE PACKAGE BODY pkg_colecao IS
    
        -- ------------------------------------------------- Funções Auxiliares ----------------------------------------------------------

        -- -------------------------------------------------------------------------------------------------------------------------------
        -- Procedimento auxiliar para lançar exceções com mensagens legíveis.
        -- -------------------------------------------------------------------------------------------------------------------------------
        PROCEDURE raise_error(codigo IN NUMBER, info IN VARCHAR2 := NULL) IS
            msg VARCHAR2(4000);
        BEGIN
            CASE codigo
                WHEN -20001 THEN msg := 'Violacao de integridade (constraint).';
                WHEN -20002 THEN msg := 'Artista inexistente.';
                WHEN -20003 THEN msg := 'Album inexistente.';
                WHEN -20004 THEN msg := 'Utilizador inexistente.';
                WHEN -20005 THEN msg := 'Registo ja existente.';
                WHEN -20006 THEN msg := 'Violação RIA-08: ano do album anterior ao início do artista.';
                WHEN -20007 THEN msg := 'Violação RIA-15: utilizador tem menos de 13 anos.';
                WHEN -20008 THEN msg := 'Violação RIA-16: data de posse anterior ao ano do álbum.';
                WHEN -20009 THEN msg := 'Violação RIA-17: data de posse anterior ao 13º ano do utilizador.';
                WHEN -20010 THEN msg := 'Posse inexistente para remoção.';
                ELSE msg := 'Erro.';
            END CASE;

            IF info IS NOT NULL THEN
                msg := msg || ' ' || info;
            END IF;

            RAISE_APPLICATION_ERROR(codigo, msg);
        END raise_error;


        -- -------------------------------------------------------------------------------------------------------------------------------
        -- Função auxiliar para contar o número de posses de um utilizador.
        -- -------------------------------------------------------------------------------------------------------------------------------
        FUNCTION count_posses(username IN utilizador.username%TYPE) RETURN NUMBER 
        IS
            counter NUMBER;
        BEGIN
            SELECT COUNT(*) INTO counter
            FROM   possui 
            WHERE  utilizador = username;

            RETURN counter;

        EXCEPTION
            WHEN OTHERS THEN
                raise_error(-20001, 'Erro ao contar posses do utilizador: ' || username);
        END count_posses;

        -- -------------------------------------------------------------------------------------------------------------------------------

        -- -------------------------------------------------------------------------------------------------------------------------------
        -- Regista um artista com ISNI, nome, e ano de início de atividade.
        -- -------------------------------------------------------------------------------------------------------------------------------
        PROCEDURE regista_artista(
            isni_in   IN artista.isni%TYPE,
            nome_in   IN artista.nome%TYPE,
            inicio_in IN artista.inicio%TYPE)
        IS
        BEGIN
            -- Inserir o novo artista
            INSERT INTO artista (isni, nome, inicio)
                VALUES (isni_in, nome_in, inicio_in);
            
        EXCEPTION
            -- PK duplicada (já existe artista com esse ISNI)
            WHEN DUP_VAL_ON_INDEX THEN
                raise_error(-20005, 'ISNI: ' || isni_in);

            WHEN OTHERS THEN
                IF SQLCODE BETWEEN -20010 AND -20001 THEN
                    RAISE;
                ELSE
                    raise_error(-20001, 'Erro ao registar artista com ISNI ' || isni_in);
                END IF;

        END regista_artista;

        -- -------------------------------------------------------------------------------------------------------------------------------
        -- Regista um álbum com EAN-13, título, tipo, ano de lançamento, artista que o interpreta, suporte físico, e, opcionalmente,
        -- a descrição da versão. O ano de lançamento do álbum tem de ser posterior ou igual ao ano de início de atividade do artista
        -- que o interpreta (RIA-08).
        -- -------------------------------------------------------------------------------------------------------------------------------
        PROCEDURE regista_album(
            ean_in     IN album.ean%TYPE,
            titulo_in  IN album.titulo%TYPE,
            tipo_in    IN album.tipo%TYPE,
            ano_in     IN album.ano%TYPE,
            artista_in IN album.artista%TYPE,
            suporte_in IN album.suporte%TYPE,
            versao_in  IN album.versao%TYPE := NULL)
        IS
            ano_inicio_artista NUMBER;
        BEGIN
            -- Obter o ano de início de atividade do artista (RIA-08)
            SELECT inicio INTO ano_inicio_artista
            FROM artista
            WHERE isni = artista_in;

            IF ano_in < ano_inicio_artista THEN
                raise_error(-20006, 'Álbum: ' || ean_in);      -- RIA-08 violada
            END IF;

            -- Inserir o novo álbum
            INSERT INTO album (ean, titulo, tipo, ano, artista, suporte, versao)
                VALUES (ean_in, titulo_in, tipo_in, ano_in, artista_in, suporte_in, versao_in);
        
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                raise_error(-20005, 'EAN: ' || ean_in);            -- Já existe registo
            
            WHEN NO_DATA_FOUND THEN
                raise_error(-20002, 'Artista: ' || artista_in);    -- Artista inexistente

            WHEN OTHERS THEN
                IF SQLCODE BETWEEN -20010 AND -20001 THEN
                    RAISE;
                ELSE
                    raise_error(-20001, 'Erro ao registar álbum com EAN: ' || ean_in);
                END IF;
        
        END regista_album;

        -- -------------------------------------------------------------------------------------------------------------------------------
        -- Regista um utilizador com username, e-mail, senha de acesso ao sistema de informação, ano de nascimento, e, opcionalmente,
        -- o artista favorito. Aquando do registo, o utilizador tem de ser 13 ou mais anos (RIA-15).
        -- -------------------------------------------------------------------------------------------------------------------------------
        PROCEDURE regista_utilizador(
            username_in   IN utilizador.username%TYPE,
            email_in      IN utilizador.email%TYPE,
            senha_in      IN utilizador.senha%TYPE,
            nascimento_in IN utilizador.nascimento%TYPE,
            artista_in    IN utilizador.artista%TYPE := NULL)
        IS
            idade NUMBER;
        BEGIN
            -- Verificar a idade do utilizador (nascimento_in é apenas o ano)
            idade := EXTRACT(YEAR FROM SYSDATE) - nascimento_in;

            IF idade < 13 THEN
                raise_error(-20007, 'Utilizador: ' || username_in);
            END IF;

            -- Inserir o novo utilizador
            INSERT INTO utilizador (username, email, senha, nascimento, artista)
                VALUES (username_in, email_in, senha_in, nascimento_in, artista_in);
        
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                raise_error(-20005, 'Username: ' || username_in || ', Email: ' || email_in);    -- Já existe registo

            WHEN OTHERS THEN
                IF SQLCODE BETWEEN -20010 AND -20001 THEN
                    RAISE;
                ELSIF SQLCODE = -2291 THEN
                    raise_error(-20002, 'Artista: ' || artista_in);  -- Artista inexistente
                ELSE
                    raise_error(-20001, 'Erro ao registar utilizador. Username: ' || username_in);
                END IF;
        END regista_utilizador;

        -- -------------------------------------------------------------------------------------------------------------------------------
        -- Regista a posse de um álbum por um utilizador desde uma data, a qual, por omissão, é o momento do registo. 
        -- A função devolve a quantidade de álbuns que o utilizador possui na sua coleção. O ano da data de posse de um álbum tem de ser
        -- posterior ou igual ao ano de lançamento do álbum (RIA-16) e também tem de ser posterior ou igual ao ano em que o utilizador 
        -- perfez 13 anos (RIA-17).
        -- -------------------------------------------------------------------------------------------------------------------------------
        FUNCTION regista_posse(
            utilizador_in IN possui.utilizador%TYPE,
            album_in      IN possui.album%TYPE,
            desde_in      IN possui.desde%TYPE := SYSDATE)
            RETURN NUMBER
        IS
            ano_lancamento NUMBER;
            ano_idade_min NUMBER;
        BEGIN
            -- Obter o ano de lançamento do álbum
            BEGIN
                SELECT ano INTO ano_lancamento
                FROM album
                WHERE ean = album_in;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    raise_error(-20003, 'EAN: ' || album_in);                   -- Álbum inexistente
            END;

            -- Obter o ano em que o utilizador fez 13 anos
            BEGIN
                SELECT nascimento + 13 INTO ano_idade_min
                  FROM utilizador
                 WHERE username = utilizador_in;
            
                EXCEPTION 
                    WHEN NO_DATA_FOUND THEN
                        raise_error(-20004, 'Username: ' || utilizador_in);     -- Utilizador inexistente
                END;

            -- RIA-16: posse não pode ser anterior ao ano de lançamento do álbum
            IF EXTRACT(YEAR FROM desde_in) < ano_lancamento THEN
                raise_error(-20008, 'EAN: ' || album_in || ', Username: ' || utilizador_in);
            END IF;

            -- RIA-17: posse não pode ser antes do 13º aniversário do utilizador
            IF EXTRACT(YEAR FROM desde_in) < ano_idade_min THEN
                raise_error(-20009, 'EAN: ' || album_in || ', Username: ' || utilizador_in);
            END IF;

            -- Inserir a posse
            INSERT INTO possui (utilizador, album, desde)
                VALUES (utilizador_in, album_in, desde_in);

            -- Retornar o número de posses do utilizador
            RETURN count_posses(utilizador_in);

        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                raise_error(-20005, 'EAN: ' || album_in || ', Username: ' || utilizador_in);    -- Já existe registo

            WHEN OTHERS THEN
                IF SQLCODE BETWEEN -20010 AND -20001 THEN
                    RAISE;
                ELSE
                    raise_error(-20001, 'Erro ao registar posse do álbum ' || album_in || ' pelo utilizador ' || utilizador_in);
                END IF;

        END regista_posse;

        -- -------------------------------------------------------------------------------------------------------------------------------
        -- Remove o registo de posse de um álbum por um utilizador. A função devolve a quantidade de álbuns que o utilizador
        -- ainda possui na sua coleção.
        -- -------------------------------------------------------------------------------------------------------------------------------
        FUNCTION remove_posse(
            utilizador_in IN possui.utilizador%TYPE,
            album_in      IN possui.album%TYPE)
            RETURN NUMBER
        IS
        BEGIN
            -- Remover a posse
            DELETE 
              FROM possui
             WHERE utilizador = utilizador_in
               AND album = album_in;

            -- Se não foi removida nenhuma linha, a posse não existia
            IF SQL%ROWCOUNT = 0 THEN
                raise_error(-20010, 'EAN: ' || album_in || ', Username: ' || utilizador_in);
            END IF; 

            -- Retornar o número de posses do utilizador
            RETURN count_posses(utilizador_in);

        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE BETWEEN -20010 AND -20001 THEN
                    RAISE;
                ELSE
                    raise_error(-20001, 'Erro ao remover posse do álbum ' || album_in || ' pelo utilizador ' || utilizador_in);
                END IF;

        END remove_posse;

        -- -------------------------------------------------------------------------------------------------------------------------------
        -- Remove o utilizador com o username, bem como os seus registos de posse de álbuns. A remoção dos registos de posse deve ser
        -- feita invocando remove_posse.
        -- -------------------------------------------------------------------------------------------------------------------------------
        PROCEDURE remove_utilizador(
            username_in IN utilizador.username%TYPE)
        IS
            CURSOR c_posses IS
                SELECT album
                FROM possui
                WHERE utilizador = username_in;

            total_posses NUMBER;
            
        -- Tabela local para armazenar os álbuns a remover
            TYPE tabela_local_posses IS TABLE OF c_posses%ROWTYPE;
            posses tabela_local_posses;
        BEGIN
            -- Carregar as posses do utilizador para a tabela local
            OPEN c_posses;
            FETCH c_posses BULK COLLECT INTO posses;
            CLOSE c_posses;

            -- Remover cada posse
            IF posses.COUNT > 0 THEN
                FOR i IN posses.FIRST .. posses.LAST LOOP
                    total_posses := remove_posse(username_in, posses(i).album);
                END LOOP;
            END IF;

            -- Remover o utilizador
            DELETE 
              FROM utilizador
             WHERE username = username_in;

            IF SQL%ROWCOUNT = 0 THEN
                raise_error(-20004, 'Username:' || username_in);
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE BETWEEN -20010 AND -20001 THEN
                    RAISE;
                ELSE
                    raise_error(-20001, 'Erro ao remover utilizador com username ' || username_in);
                END IF;
        END remove_utilizador;

        -- -------------------------------------------------------------------------------------------------------------------------------
        -- Remove o álbum com o EAN-13, bem como todos os registos de posse desse álbum, qualquer que seja o utilizador. 
        -- A remoção de registos de posse deve ser feita invocando remove_posse.
        -- -------------------------------------------------------------------------------------------------------------------------------
        PROCEDURE remove_album(
            ean_in IN album.ean%TYPE)
        IS
            -- Cursor para obter os utilizadores que possuem o álbum
            CURSOR c_posses IS
                SELECT utilizador
                FROM possui
                WHERE album = ean_in;
            
            total_posses NUMBER;

            -- Tabela local para armazenar os utilizadores a remover
            TYPE tabela_local_posses IS TABLE OF c_posses%ROWTYPE;
            posses tabela_local_posses;

        BEGIN
            -- Carregar os utilizadores que possuem o álbum para a tabela local
            OPEN c_posses;
            FETCH c_posses BULK COLLECT INTO posses;
            CLOSE c_posses;

            IF posses.COUNT > 0 THEN
                -- Remover cada posse posse
                FOR i IN posses.FIRST .. posses.LAST LOOP
                    total_posses := remove_posse(posses(i).utilizador, ean_in);
                END LOOP;
            END IF;

            -- Remover o álbum
            DELETE 
              FROM album
             WHERE ean = ean_in;
            
            IF SQL%ROWCOUNT = 0 THEN
                raise_error(-20003, 'EAN: ' || ean_in);
            END IF;
        
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE BETWEEN -20010 AND -20001 THEN
                    RAISE;
                ELSE
                    raise_error(-20001, 'Erro ao remover álbum com EAN ' || ean_in);
                END IF;
        END remove_album;

        -- -------------------------------------------------------------------------------------------------------------------------------
        -- Remove o artista com o ISNI, bem como os álbuns que interpretou. A remoção de álbuns deve ser feita invocando remove_album.
        -- -------------------------------------------------------------------------------------------------------------------------------
        PROCEDURE remove_artista(
            isni_in IN artista.isni%TYPE)
        IS
            -- Cursor para obter todos os álbuns do artista
            CURSOR c_albuns IS
                SELECT ean
                FROM album
                WHERE artista = isni_in;
            
            -- Tabela local para armazenar os álbuns a remover
            TYPE tabela_local_albuns IS TABLE OF c_albuns%ROWTYPE;
            albuns tabela_local_albuns;
        
        BEGIN
            -- Carregar os álbuns do artista para a tabela local
            OPEN c_albuns;
            FETCH c_albuns BULK COLLECT INTO albuns;
            CLOSE c_albuns;

            -- Remover cada álbum
            IF albuns.COUNT > 0 THEN
                FOR i IN albuns.FIRST .. albuns.LAST LOOP
                    remove_album(albuns(i).ean);
                END LOOP;
            END IF;

            -- Remover o artista
            DELETE 
              FROM artista
             WHERE isni = isni_in;

            IF SQL%ROWCOUNT = 0 THEN
                raise_error(-20002, 'ISNI: ' || isni_in);
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE BETWEEN -20010 AND -20001 THEN
                    RAISE;
                ELSE
                    raise_error(-20001, 'Erro ao remover artista com ISNI ' || isni_in);
                END IF;
        END remove_artista;

        -- -------------------------------------------------------------------------------------------------------------------------------
        -- Devolve um cursor com os álbuns que um utilizador possui na sua coleção, com ordenação descendente pelo ano de lançamento
        -- do álbum, e ascendente pelo nome do artista e título do álbum. Cada linha do cursor deve ter o EAN-13, título, tipo,
        -- ano de lançamento, suporte físico, e versão de um álbum, bem como o nome do artista que o interpretou, nome esse que deve
        -- terminar com um asterisco se for o artista favorito do utilizador (por exemplo, Day6* ou Dire Straits*).
        -- -------------------------------------------------------------------------------------------------------------------------------
        FUNCTION lista_albuns(
            utilizador_in IN utilizador.username%TYPE)
            RETURN SYS_REFCURSOR
        IS
            c_lista SYS_REFCURSOR;
        BEGIN
            OPEN c_lista FOR
                SELECT AL.ean, AL.titulo, AL.tipo, AL.ano, AL.suporte, AL.versao,
                    -- Se for o artista favorito, acrescentar asterisco
                    CASE 
                        WHEN UT.artista = AR.isni THEN AR.nome || '*'
                        ELSE AR.nome
                    END AS nome_artista
                FROM album AL, artista AR, possui PO, utilizador UT
                WHERE AL.artista = AR.isni
                AND AL.ean = PO.album
                AND PO.utilizador = UT.username          -- Condições de junção
                AND UT.username = utilizador_in
                ORDER BY AL.ano DESC, AR.nome ASC, AL.titulo ASC;

            RETURN c_lista;
        
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE BETWEEN -20010 AND -20001 THEN
                    RAISE;
                ELSE
                    raise_error(-20001, 'Erro ao listar álbuns do utilizador ' || utilizador_in);
                END IF;
        END lista_albuns;
    END pkg_colecao;
    /