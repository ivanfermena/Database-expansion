set serveroutput on
set autocommit off

CREATE SEQUENCE sec_T1
MINVALUE 0 MAXVALUE 1 INCREMENT BY 1 
START WITH 0  
NOCACHE
CYCLE ;

CREATE SEQUENCE sec_T2
MINVALUE 0 MAXVALUE 1 INCREMENT BY 1 
START WITH 0  
NOCACHE
CYCLE ;

create or replace PROCEDURE trabajando_T1(num_seg INTEGER)
AS
anterior_seq_val INTEGER;
actual_seq_val INTEGER;
numero_T VARCHAR(50);
BEGIN
    anterior_seq_val := sec_T1.nextval;
    LOOP
        actual_seq_val := sec_T1.nextval;
        EXIT WHEN anterior_seq_val = actual_seq_val;
        anterior_seq_val := actual_seq_val;
        DBMS_OUTPUT.put_line('Soy T1, me voy a dormir');
        ABDMIUTIL.dormir(num_seg);
    END LOOP;
    select DBMS_TRANSACTION.LOCAL_TRANSACTION_ID INTO numero_T FROM dual;
    DBMS_OUTPUT.put_line('Se ha dormido la transaccion: ' || numero_T);
END trabajando_T1;
 
create or replace PROCEDURE trabajando_T2(num_seg INTEGER)
AS
anterior_seq_val INTEGER;
actual_seq_val INTEGER;
numero_T VARCHAR(50);
BEGIN
    anterior_seq_val := sec_T2.nextval;
    LOOP
        actual_seq_val := sec_T2.nextval;
        EXIT WHEN anterior_seq_val = actual_seq_val;
        anterior_seq_val := actual_seq_val;
        DBMS_OUTPUT.put_line('Soy T2, me voy a dormir');
        ABDMIUTIL.dormir(num_seg);
    END LOOP;
    select DBMS_TRANSACTION.LOCAL_TRANSACTION_ID INTO numero_T FROM dual;
    DBMS_OUTPUT.put_line('Se ha dormido la transaccion: ' || numero_T);
END trabajando_T2;
 