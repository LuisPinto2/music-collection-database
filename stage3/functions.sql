CREATE OR REPLACE FUNCTION decada_de_ano (p_ano IN NUMBER) 
RETURN NUMBER IS
BEGIN
    RETURN TRUNC(p_ano, -1);
END decada_de_ano;
/