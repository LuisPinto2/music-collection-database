    CREATE OR REPLACE PACKAGE pkg_colecao IS

        -- Todas as operações lançam exceções para sinalizar casos de erro.
        --
        -- Exceção Mensagem
        -- -20001  Violação de integridade (constraint).
        -- -20002  Artista inexistente.
        -- -20003  Álbum inexistente.
        -- -20004  Utilizador inexistente.
        -- -20005  Registo já existente.
        -- -20006  Violação RIA-08: ano do álbum anterior ao início do artista.
        -- -20007  Violação RIA-15: utilizador tem menos de 13 anos.
        -- -20008  Violação RIA-16: data de posse anterior ao ano do álbum.
        -- -20009  Violação RIA-17: data de posse anterior ao 13º ano do utilizador.
        -- -20010  Posse inexistente para remoção.

        -- Tipo de cursor álbuns
        TYPE ref_album_cursor IS REF CURSOR;

        PROCEDURE regista_artista(
            isni_in   IN artista.isni%TYPE,
            nome_in   IN artista.nome%TYPE,
            inicio_in IN artista.inicio%TYPE);

        PROCEDURE regista_album(
            ean_in     IN album.ean%TYPE,
            titulo_in  IN album.titulo%TYPE,
            tipo_in    IN album.tipo%TYPE,
            ano_in     IN album.ano%TYPE,
            artista_in IN album.artista%TYPE,
            suporte_in IN album.suporte%TYPE,
            versao_in  IN album.versao%TYPE := NULL);

        PROCEDURE regista_utilizador(
            username_in   IN utilizador.username%TYPE,
            email_in      IN utilizador.email%TYPE,
            senha_in      IN utilizador.senha%TYPE,
            nascimento_in IN utilizador.nascimento%TYPE,
            artista_in    IN utilizador.artista%TYPE := NULL);

        FUNCTION regista_posse(
            utilizador_in IN possui.utilizador%TYPE,
            album_in      IN possui.album%TYPE,
            desde_in      IN possui.desde%TYPE := SYSDATE)
            RETURN NUMBER;

        FUNCTION remove_posse(
            utilizador_in IN possui.utilizador%TYPE,
            album_in      IN possui.album%TYPE)
            RETURN NUMBER;

        PROCEDURE remove_utilizador(
            username_in IN utilizador.username%TYPE);

        PROCEDURE remove_album(
            ean_in IN album.ean%TYPE);

        PROCEDURE remove_artista(
            isni_in IN artista.isni%TYPE);

        FUNCTION lista_albuns(
            utilizador_in IN utilizador.username%TYPE)
            RETURN SYS_REFCURSOR;

    END pkg_colecao;
    /