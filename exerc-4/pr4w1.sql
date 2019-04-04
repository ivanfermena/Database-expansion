--------- PRACTICA 8 - OPTIMIZACION --------- 

/**
    ---- APARTADO 2 ----
*/

-- A)

    -- CONSULTA 1 --
    
    delete plan_table;
    
    EXPLAIN PLAN 
        INTO plan_table
        FOR (select * from cliente where DNI < '00000005') union
            (select * from moroso where NombreC = 'Client E');
    
    -- CONSULTA 2 --
    
    delete plan_table; /* borra las tuplas de explicación anterior*/
    EXPLAIN PLAN
        INTO plan_table
        FOR (select * from cliente where DNI = '00000005') union
            (select * from moroso where NombreC = 'Client E');
    
    -- CONSULTA 3 -- anidados --
    
    delete plan_table;
    EXPLAIN PLAN
        INTO plan_table
        FOR select * from cliente where DNI in
            (select DNI from moroso where NombreC = 'Client E');
    
    -- CONSULTA 4 --
    
    delete plan_table;
    EXPLAIN PLAN
        INTO plan_table
        FOR (select * from cliente where dni in
            (select dni from invierte));
    
    -- CONSULTA 5 --
    
    delete plan_table; /* borra las tuplas de explicación anterior*/
    EXPLAIN PLAN
        INTO plan_table
        FOR (select * from cliente where dni in
            (select dni from invierte where cantidad < 30000));
    
    -- CONSULTA 6 -
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

-- MASCARA PARA CONSULTAR LA TABLA DEL PLAN --

-- Lanzar para ver el correctao funcionamiento de la consulta ---

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
