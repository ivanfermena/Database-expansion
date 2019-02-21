create or replace PROCEDURE crea_sec_inversion(NombreEmpresa VARCHAR2)
AS
existe_sec NUMBER;
plsql_block VARCHAR(2000);
BEGIN

    select count(object_name)  into existe_sec 
    from user_objects
    where object_type ='SEQUENCE' and 
       object_name =  RTRIM( UPPER('sec_'|| NombreEmpresa));
    
    
    IF existe_sec = 0 THEN
        plsql_block := 'CREATE SEQUENCE sec_' || NombreEmpresa || ' START WITH 1
        INCREMENT BY 1
        MAXVALUE 999';
        EXECUTE IMMEDIATE plsql_block;
        commit;
        DBMS_output.put_line('--- sec_' || NombreEmpresa || ' creada ');
    END IF;
END crea_sec_inversion;

create or replace PROCEDURE crea_tabla_inversiones(NombreEmpresa VARCHAR2, NumSec NUMBER)
AS
existe_tabla NUMBER;
plsql_block VARCHAR(2000);

BEGIN
    select count(table_name) into existe_tabla from tabs where table_name =
        RTRIM( UPPER('inversiones_' || NombreEmpresa));
    
    
    IF existe_tabla = 0 THEN
        plsql_block := 'create table inversiones_' || NombreEmpresa ||
        ' (NumInv NUMBER(38,0),
        DNI CHAR(8) not null,
        Cantidad FLOAT,
        Tipo CHAR(10),
        PRIMARY KEY (NumInv))' ;
        EXECUTE IMMEDIATE plsql_block;
        commit;
        DBMS_output.put_line('--- tabla inversiones_' || NombreEmpresa || ' creada ');
    END IF;
END crea_tabla_inversiones;


create or replace PROCEDURE gestion_inversion(
DNI Invierte.DNI%TYPE,
NombreEmpresa Invierte.NombreE%TYPE,
Cantidad Invierte.Cantidad%TYPE,
Tipo Invierte.Tipo%TYPE)
AS
existe_empresa NUMBER;
plsql_block VARCHAR(2000);
BEGIN

    select count(table_name) into existe_empresa from tabs where table_name =
        RTRIM( UPPER(NombreEmpresa));
    
    
    IF existe_empresa <> 0 THEN
        begin
        crea_sec_inversion(NombreEmpresa);
        end;
        
        begin
        crea_sec_inversion(crea_tabla_inversiones, 'sec_' || NombreEmpresa);
        end;
        
        plsql_block := 'BEGIN insert into inversiones_' || NombreEmpresa || ' values (:b, :c, :d, :e); END;';
        DBMS_output.put_line('--- insert dinámico en tabla inversiones_' || NombreEmpresa);
        EXECUTE IMMEDIATE plsql_block USING IN
        ('sec_' || NombreEmpresa).nextval, DNI, Cantidad, Tipo;
        commit;
    END IF;
END gestion_inversion;


INSERT INTO Empresa VALUES ('Empresa11', 111111, 110000.00);
INSERT INTO Empresa VALUES ('Empresa22', 222222, 220000.00);
INSERT INTO Empresa VALUES ('Empresa100', 333333, 330000.00);

SET SERVEROUTPUT ON SIZE 100000;

 -- TEST 'CREA_SEC_INVERSION'
begin
crea_sec_inversion('empresa11');
end;

begin
crea_sec_inversion('Empresa100');
end;

begin
crea_sec_inversion('Empresa22');
end;

 -- TEST 'CREA_TABLA_INVERSIONES'
begin
crea_tabla_inversiones('Empresa11', 12);
end;

begin
crea_tabla_inversiones('Empresa100');
end;

begin
crea_tabla_inversiones('Empresa22');
end;

 -- TEST 'GESTION_INVERSION'
begin
gestion_inversion('Empresa11');
end;

begin
gestion_inversion('Empresa100');
end;

begin
gestion_inversion('Empresa22');
end;

