-- CONSULTA 6
delete plan_table;
    EXPLAIN PLAN 
        INTO plan_table
        FOR 
        (select distinct NombreC
            from Cliente, Compras, Invierte
            where Cliente.DNI = Invierte.DNI and
                  Invierte.NombreE = 'Empresa 55' and
                  Compras.DNI = Cliente.DNI and
                  Compras. Importe >1000);

-- PLOT DEL PLAN DE EJECUCION

ttitle ' INFORME DEL PLAN  '

col operation   heading 'OPERACION' format a12 word_wrapped
col options     heading 'OPCIONES' format a12 word_wrapped
col object_name heading 'TABLA'    format a12 word_wrapped
col cost        heading 'Coste'    format a5
col cardinality heading 'Filas'    format a5
col parent_id   heading 'PADRE'    format a5
col id          heading 'Id_Fila'  format a5

 select operation,options,object_name,cost,cardinality,parent_id,id 
 from plan_table
 connect by prior id=parent_id    -- and statement_id= 'actuaT'
 start with id = 1                -- and statement_id= 'actuaT'
 order by id;
 
/

-- CREACION CLAVES PRIMARIAS

ALTER TABLE PELISHIST ADD CONSTRAINT PK_pelishist PRIMARY KEY (id);
ALTER TABLE PELISAHORA ADD CONSTRAINT PK_pelisahora PRIMARY KEY (id);

-- CREACION INDICES SOBRE CAMPO 'TITULO'

CREATE INDEX ind_titulohist ON PELISHIST (titulo);
CREATE INDEX ind_tituloahora ON PELISAHORA (titulo);

-- CONSULTAS APARTADO 3
-- 

-- CONSULTA 1
delete plan_table;
    EXPLAIN PLAN 
        INTO plan_table
        FOR 
        (select PELISAHORA.ID
        from PELISAHORA, PELISHIST
        where PELISAHORA.ID = PELISHIST.ID);

-- CONSULTA 2
delete plan_table;
    EXPLAIN PLAN 
        INTO plan_table
        FOR 
        (select PELISAHORA.DESCRIPCION
        from PELISAHORA, PELISHIST
        where PELISAHORA.DESCRIPCION = PELISHIST.DESCRIPCION);
        
-- CONSULTA 3
delete plan_table;
    EXPLAIN PLAN 
        INTO plan_table
        FOR 
        (select PELISAHORA.TITULO
        from PELISAHORA, PELISHIST
        where PELISAHORA.TITULO = PELISHIST.TITULO);

-- CONSULTA 4
delete plan_table;
    EXPLAIN PLAN 
        INTO plan_table
        FOR 
        (select PELISAHORA.TITULO
        from PELISAHORA
        where PELISAHORA.TITULO IN (SELECT PELISHIST.TITULO FROM PELISHIST));

-- CONSULTA 5
delete plan_table;
    EXPLAIN PLAN 
        INTO plan_table
        FOR 
        (select PELISAHORA.TITULO
        from PELISAHORA
        where PELISAHORA.TITULO IN (SELECT PELISHIST.TITULO FROM PELISHIST 
                                    WHERE PELISAHORA.TITULO = PELISHIST.TITULO));

-- Consulta por 'genero' 1

delete plan_table;
    EXPLAIN PLAN 
        INTO plan_table
        FOR 
        (select PELISAHORA.TITULO, ROUND(DRAMA)
        from PELISAHORA
        where PELISAHORA.GENERO = 'Drama' AND ROUND(PELISAHORA.DRAMA) > 35);
        
        
-- Consulta por 'genero' 2

delete plan_table;
    EXPLAIN PLAN 
        INTO plan_table
        FOR 
        (select PELISAHORA.TITULO, ROUND(DRAMA)
        from PELISAHORA
        where PELISAHORA.GENERO = 'Drama' AND ROUND(PELISAHORA.DRAMA) > 10);
        
-- Consulta con full table scan

delete plan_table;
    EXPLAIN PLAN 
        INTO plan_table
        FOR 
        (select PELISAHORA.TITULO
        from PELISAHORA
        where PELISAHORA.GENERO = 'Comedia');
        
-- Consulta con index unique scan

delete plan_table;
    EXPLAIN PLAN 
        INTO plan_table
        FOR 
        (select PELISAHORA.TITULO
        from PELISAHORA
        where PELISAHORA.ID = 2);  
        
-- Consulta con full index scan

delete plan_table;
    EXPLAIN PLAN 
        INTO plan_table
        FOR 
        (select PELISAHORA.ID
        from PELISAHORA
        where PELISAHORA.ID = 2);
           
-- Consulta con cartesian join

delete plan_table;
    EXPLAIN PLAN 
        INTO plan_table
        FOR 
        (select *
        from PELISAHORA, PELISHIST);
        
        
-- Consulta apartado e

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());


