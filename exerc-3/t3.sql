-- 3
set serveroutput on
set autocommit off

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;


select DBMS_TRANSACTION.LOCAL_TRANSACTION_ID  FROM dual;

select sec_T1.nextval from dual;

select sec_T2.nextval from dual;

begin
    for rec in (select * from compras)
    loop
        dbms_output.put_line('DNI: '|| rec.dni || ' NUMT: ' || rec.numt || ' NUMF: ' || rec.numf);
    end loop;
end;

select sec_T1.nextval from dual;

select sec_T2.nextval from dual;

begin
    for rec in (select * from compras)
    loop
        dbms_output.put_line('DNI: '|| rec.dni || ' NUMT: ' || rec.numt || ' NUMF: ' || rec.numf);
    end loop;
end;