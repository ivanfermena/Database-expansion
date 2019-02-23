create or replace PROCEDURE insertoConsistente (
-- Argumentos de entrada
DNI_p        invierte.DNI%TYPE,
NombreE_p    invierte.NombreE%TYPE,
Cantidad_p   invierte.Cantidad%TYPE,
Tipo_p       invierte.Tipo%TYPE
)  AS


-- vars de trabajo

invierte_oldrow_DNI  invierte.DNI%TYPE;
invierte_oldrow_Tipo  invierte.Tipo%TYPE;
invierte_oldrow_NombreE  invierte.NombreE%TYPE;


-- para excepciones 
  Tcoderror NUMBER;
  Ttexterror VARCHAR2(100);

  inconsistencia EXCEPTION;

BEGIN

DBMS_output.put_line('Queries para almacenar datos antiguos');

-- Decido si ese DNI es nuevo (no tiene inversiones) : si 0 es nuevo
SELECT DNI INTO invierte_oldrow_DNI
FROM invierte WHERE DNI = DNI_p;

IF invierte_oldrow_DNI <> 0 THEN -- El cliente no es nuevo
  DBMS_output.put_line('Cliente existente');
  -- Decido si es Tipo nuevo para ese cliente: si 0 es nuevo
  SELECT Tipo INTO invierte_oldrow_Tipo
  FROM invierte WHERE DNI = DNI_p AND Tipo = Tipo_p;
  -- Decido si es empresa nueva para ese cliente: si 0 es nuevo
  SELECT NombreE INTO invierte_oldrow_NombreE
  FROM invierte WHERE DNI = DNI_p AND Tipo = NombreE_p;
ELSE 
  invierte_oldrow_Tipo := 0;
  invierte_oldrow_NombreE := 0;
END IF;


DBMS_output.put_line('Aqui empieza INSERTOCONSISTENTE');

--------- muestro los datos de entrada (par�metros) con los que trabajo

DBMS_output.put_line('Datos de entrada: DNI: ' || DNI_p || ' NombreE: ' 
|| NombreE_p || ' Cantidad: ' || Cantidad_p || ' Tipo: ' || Tipo_p);

-- CASO 0.- No hay inversiones de ese DNI: inserto la fila y termino
IF invierte_oldrow_DNI = 0 THEN
  DBMS_output.put_line('CASO 0');
  INSERT INTO invierte VALUES (DNI_p, NombreE_p, Cantidad_p, Tipo_p);
ELSE
  -- CASO 1.-  Ya existe una fila con mismo Tipo (1) y Empresa (1) : es un error, no se lo permito
  IF invierte_oldrow_Tipo <> 0 AND invierte_oldrow_NombreE <> 0 THEN
    DBMS_output.put_line('CASO 1');
    RAISE inconsistencia;
  -- CASO 2.-  tipo nuevo para una Empresa que ya hay inversiones: debo insertar filas con ese tipo para todas sus empresas
  ELSIF invierte_oldrow_Tipo = 0 AND invierte_oldrow_NombreE <> 0 THEN
    DBMS_output.put_line('CASO 2');
    RAISE inconsistencia;
  -- CASO 3.- Empresa nueva para un tipo que ya hay inversiones: debo insertar filas con ese empresa para todos sus tipos
  --          No tomo en cuenta la nueva cantidad (es complejo comprobar la antig�a si hay varias empresas con ese Tipo)
  ELSIF invierte_oldrow_Tipo <> 0 AND invierte_oldrow_NombreE = 0 THEN
    DBMS_output.put_line('CASO 3');
    RAISE inconsistencia;
  -- CASO 4.- El tipo y la empresa son nuevos: Como  CASO 2 + CASO 3
  --          para cada empresa que hab�a tengo que insertar el bono nuevo
  ELSE
    DBMS_output.put_line('CASO 4');
    RAISE inconsistencia;

  END IF;
END IF;

EXCEPTION
  WHEN inconsistencia THEN
  Tcoderror:= SQLCODE;
	Ttexterror:= SUBSTR(SQLERRM,1, 100);
   DBMS_output.put_line('Sale por una excepcion: ' || Tcoderror ||   '  -- ' || Ttexterror );
   DBMS_output.put_line('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$' );
   
  WHEN OTHERS THEN
	Tcoderror:= SQLCODE;
	Ttexterror:= SUBSTR(SQLERRM,1, 100);
   DBMS_output.put_line('Sale por una excepcion: ' || Tcoderror ||   '  -- ' || Ttexterror );
   DBMS_output.put_line('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$' ); 


END insertoConsistente;

/

show errors
