-- 2
set serveroutput on
set autocommit off


select DBMS_TRANSACTION.LOCAL_TRANSACTION_ID  FROM dual;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

create or replace PROCEDURE probarMiT2
AS
BEGIN
    DBMS_OUTPUT.put_line('Inicio T2');
    for rec in (select * from compras)
    loop
        dbms_output.put_line('DNI: '|| rec.dni || ' NUMT: ' || rec.numt || ' NUMF: ' || rec.numf);
    end loop;
    INSERT INTO Compras VALUES ('00000005', '50000400', 700, 0501,'tienda1',50);
    INSERT INTO Compras VALUES ('00000005', '50000400', 800, 0501,'tienda1',5);
    INSERT INTO Compras VALUES ('00000005', '50000400', 900, 0502,'tienda1',500);
    trabajando_T2(5);
    DBMS_OUTPUT.put_line('Tras siesta 1 en T2');
    for rec in (select * from compras)
    loop
        dbms_output.put_line('DNI: '|| rec.dni || ' NUMT: ' || rec.numt || ' NUMF: ' || rec.numf);
    end loop;
    INSERT INTO Compras VALUES ('00000005', '50000400', 1000, 0501,'tienda1',50);
    INSERT INTO Compras VALUES ('00000005', '50000400', 1100, 0501,'tienda1',5);
    INSERT INTO Compras VALUES ('00000005', '50000400', 1200, 0502,'tienda1',500);
    trabajando_T2(5);
    DBMS_OUTPUT.put_line('Tras siesta 2 en T2');
    for rec in (select * from compras)
    loop
        dbms_output.put_line('DNI: '|| rec.dni || ' NUMT: ' || rec.numt || ' NUMF: ' || rec.numf);
    end loop;
END;

execute probarMiT2;
