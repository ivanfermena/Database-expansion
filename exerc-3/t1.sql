-- 1
set serveroutput on
set autocommit off


select DBMS_TRANSACTION.LOCAL_TRANSACTION_ID  FROM dual;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

CREATE OR REPLACE  PROCEDURE probarMiT1
AS
BEGIN
    DBMS_OUTPUT.put_line('Inicio T1');
    for rec in (select * from compras)
    loop
        dbms_output.put_line('DNI: '|| rec.dni || ' NUMT: ' || rec.numt || ' NUMF: ' || rec.numf);
    end loop;
    INSERT INTO Compras VALUES ('00000005', '50000400',100, 0501,'tienda1',50);
    INSERT INTO Compras VALUES ('00000005', '50000400',200, 0501,'tienda1',5);
    INSERT INTO Compras VALUES ('00000005', '50000400',300, 0502,'tienda1',500);
    trabajando_T1(5);
    DBMS_OUTPUT.put_line('Tras siesta 1 en T1');
    for rec in (select * from compras)
    loop
        dbms_output.put_line('DNI: '|| rec.dni || ' NUMT: ' || rec.numt || ' NUMF: ' || rec.numf);
    end loop;
    INSERT INTO Compras VALUES ('00000005', '50000400',400, 0501,'tienda1',50);
    INSERT INTO Compras VALUES ('00000005', '50000400',500, 0501,'tienda1',5);
    INSERT INTO Compras VALUES ('00000005', '50000400',600, 0502,'tienda1',500);
    trabajando_T1(5);
    DBMS_OUTPUT.put_line('Tras siesta 2 en T1');
    for rec in (select * from compras)
    loop
        dbms_output.put_line('DNI: '|| rec.dni || ' NUMT: ' || rec.numt || ' NUMF: ' || rec.numf);
    end loop;
END;

select DBMS_TRANSACTION.LOCAL_TRANSACTION_ID  FROM dual;
execute probarMiT1;
select DBMS_TRANSACTION.LOCAL_TRANSACTION_ID  FROM dual;

