    ----------------------------------------------------------------------------------------------------------------------------------
    -- NOTE: The queries below were designed based on the relational schema
    -- and the `decada_de_ano` function provided by the teaching staff in the Stage 3 specifications.
    -- NOTA: As consultas abaixo foram desenhadas sobre o esquema relacional
    -- e a função `decada_de_ano` facultados pela equipa docente no enunciado da Etapa 3.
    ----------------------------------------------------------------------------------------------------------------------------------

    -- 1.
        -- EN: Username and email of users born in 1990 whose favorite artist is 'Day6' 
        --     and who registered ownership of albums by that artist in 2025. Display the album's EAN, 
        --     title, year, and the number of days elapsed since the ownership registration date. 
        --     Order by username ASC, days DESC, EAN DESC.
        -- PT: Username e e-mail dos utilizadores nascidos em 1990, com artista favorito 'Day6', 
        --     que em 2025 registaram a posse de álbuns desse artista. Mostrar EAN, título, ano do álbum
        --     e número de dias desde o registo de posse. Ordenar por username ASC, dias DESC, EAN DESC.

      SELECT UT.username, UT.email, AL.ean, AL.titulo, AL.ano,
            (SYSDATE - PO.desde) AS dias_desde_registo_posse
        FROM utilizador UT, artista AR, possui PO, album AL
      WHERE UT.artista = AR.isni
        AND UT.username = PO.utilizador
        AND PO.album = AL.ean
        AND AL.artista = AR.isni
        AND UT.nascimento = 1990
        AND AR.nome = 'Day6'
        AND TO_CHAR(PO.desde, 'YYYY') = 2025
      ORDER BY UT.username ASC, dias_desde_registo_posse DESC, AL.ean DESC;

    -- 2.
        -- EN: Username of users with an email address ending in 'gmail.com' who, considering only ownership 
        --     records registered between 2000 and 2020, either do not own albums performed by the artist 
        --     'Dire Straits' or own at most three albums by that artist. Additionally, users must not 
        --     own any 'single' type albums, regardless of the artist or registration year. 
        --     The result must be ordered by username in ascending order.
        -- PT: Username dos utilizadores com endereço de e-mail no gmail.com que, considerando apenas os registos
        --     de posse efetuados entre 2000 e 2020, ou não possuem álbuns interpretados pelo artista Dire Straits, 
        --     ou possuem no máximo três álbuns desse artista. Adicionalmente, os utilizadores não podem possuir álbuns 
        --     do tipo single, seja qual for o artista e o ano do registo. O resultado deve vir ordenado pelo username de forma ascendente.

    SELECT UT.username
      FROM utilizador UT
     WHERE UT.email LIKE '%@gmail.com'
       AND UT.username NOT IN (
            -- Users that own 'single' type albums
        SELECT PO.utilizador
          FROM possui PO, album AL
         WHERE PO.album = AL.ean
           AND AL.tipo = 'single'
    )
       AND    UT.username NOT IN (
            -- Users that own more than 3 'Dire Straits' albums
        SELECT PO.utilizador
          FROM possui PO, album AL, artista AR
         WHERE PO.album = AL.ean
           AND AL.artista = AR.isni
           AND AR.nome = 'Dire Straits'
           AND TO_CHAR(PO.desde, 'YYYY') BETWEEN 2000 AND 2020
        GROUP BY PO.utilizador
        HAVING COUNT(*) > 3
    )
    ORDER BY UT.username ASC;

    -- 3.
        -- EN: Name and activity start year of artists such that all users born from 2000 onwards 
        --     have registered ownership of at least one album performed by these artists, subject 
        --     to the following additional constraints: only artists who have released one or more 
        --     albums in the last two years, and the ownership registration timestamps must fall 
        --     between 12:00 PM and 7:59 PM. The result must be ordered by artist name in ascending 
        --     order and by activity start year in descending order. 
        --     Note: ownership registration timestamps include hours and minutes.
        -- PT: Nome e ano de início de atividade de artistas tais que todos os utilizadores nascidos de 2000 em diante tenham 
        --     registado a posse de pelo menos um álbum interpretado por esses artistas, com as seguintes restrições adicionais: 
        --     só artistas que tenham lançado um ou mais álbuns nos dois últimos anos, e os registos de posse dos utilizadores têm 
        --     de ter sido feitos entre as 12h e as 19h59. O resultado deve vir ordenado por nome de artista de forma ascendente e 
        --     pelo seu ano de início de atividade de forma descendente. Nota: a data de um registo de posse de álbum também guarda 
        --     as horas e minutos.
        
    SELECT AR.nome, AR.inicio
      FROM artista AR
      WHERE AR.isni IN (
            -- Artists with at least one album on the last 2 years
            SELECT AL.artista
              FROM album AL
              WHERE AL.artista = AR.isni
                AND AL.ano >= TO_CHAR(SYSDATE, 'YYYY') - 1
      )
      AND NOT EXISTS (
              -- There is no user born after 2000 who
              -- does not have a registered album by this artist
              SELECT *
                FROM utilizador UT
                WHERE UT.nascimento >= 2000
                  AND NOT EXISTS (
                      SELECT *
                        FROM possui PO, album AL
                        WHERE PO.album = AL.ean
                          AND AL.artista = AR.isni
                          AND TO_CHAR(PO.desde, 'HH24') BETWEEN '12' AND '19'       -- 19:59 HH24 = 19
                  )
        )
    ORDER BY AR.nome ASC, AR.inicio DESC;

    -- 4.
        -- EN: Username of the users with the highest number of vinyl album ownership records for each 
        --     year, calculated separately for users born in the 1980s and 1990s. The user's birth decade 
        --     and the total number of album ownership records in that year must also be included in 
        --     the result. The output must be sorted in descending order by year and ascending order 
        --     by birth decade. In case of a tie (multiple users born in the same decade with the same 
        --     maximum number of records in a given year), all such users must be displayed. 
        --     Note: for convenience, the helper function `decada_de_ano` is available to round a 4-digit 
        --     year to its decade (e.g., decada_de_ano(2025) = 2020).
        -- PT: Username dos utilizadores com mais registos de posse de álbuns em suporte vinil em cada ano, separadamente para 
        --     utilizadores nascidos nas décadas de 1980 e 1990, devendo a década de nascimento dos utilizadores e o número total 
        --     de registos de posse de álbuns em cada ano também aparecer no resultado. A ordenação do resultado deve ser descendente 
        --     pelo ano e ascendente pela década de nascimento dos utilizadores. No caso de haver mais do que um utilizador nascido 
        --     na mesma década e com o mesmo número máximo de registos de posse de álbuns num ano, devem ser mostrados todos esses 
        --     utilizadores. Nota: por conveniência, está disponível a função decada_de_ano, que arredonda um ano com quatro dígitos 
        --     à década; por exemplo, decada_de_ano(2025) = 2020.

      -- Number of vinyl records per user, decade, and year
      SELECT UT.username, decada_de_ano(UT.nascimento) AS decada,
             TO_CHAR(PO.desde, 'YYYY') AS ano_registo,
             COUNT (*) AS total_registos
        FROM utilizador UT, possui PO, album AL
       WHERE PO.utilizador = UT.username
         AND PO.album = AL.ean
         AND AL.suporte = 'vinil'
         AND decada_de_ano(UT.nascimento) IN (1980, 1990)
      GROUP BY UT.username, decada_de_ano(UT.nascimento), TO_CHAR(PO.desde, 'YYYY')       -- Each unique combination will result in a separate row
      HAVING COUNT(*) = (
        -- Maximum number of vinyl ownership records across all users in that specific year
        SELECT MAX(COUNT(*))
          FROM utilizador UT2, possui PO2, album AL2
         WHERE PO2.utilizador = UT2.username
           AND PO2.album = AL2.ean
           AND AL2.suporte = 'vinil'
           AND decada_de_ano(UT2.nascimento) = decada_de_ano(UT.nascimento)
           AND TO_CHAR(PO2.desde, 'YYYY') = TO_CHAR(PO.desde, 'YYYY')
        GROUP BY UT2.username
      )
      ORDER BY ano_registo DESC, decada ASC;