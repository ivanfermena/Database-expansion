SET SERVEROUTPUT ON
SET AUTOCOMMIT OFF

CREATE TABLE NOTIFICACIONES(
    USUARIO_ORIGEN VARCHAR2(200) NOT NULL,
    FECHA DATE NOT NULL,
    DNI_CLI VARCHAR2(200) NOT NULL,
    NOMBREE VARCHAR2(9),
    TIPO VARCHAR2(200),
    COMISION FLOAT,
    PRIMARY KEY(USUARIO_ORIGEN, FECHA)
)

GRANT INSERT, SELECT ON NOTIFICACIONES TO PUBLIC

-- 
--
-- APARTADO A
CREATE OR REPLACE TRIGGER PRAC36_A
AFTER INSERT ON INVIERTE
FOR EACH ROW
DECLARE
    v_code  NUMBER;
    v_errm  VARCHAR2(64);
BEGIN 
    DBMS_output.put_line('LANZADO TRIGGER PRAC36_A');
    REGALACOMISIONES(:new.NOMBREE, :new.DNI, :new.CANTIDAD, :new.TIPO);
    DBMS_output.put_line('--- trigger PRAC36_A lanzado para DNI: ' || :new.DNI ||  ' NOMBRE: ' ||:new.NOMBREE || ' CANTIDAD: ' || :new.CANTIDAD || ' TIPO: ' || :new.TIPO);
EXCEPTION
    WHEN OTHERS THEN
        v_code := SQLCODE;
        v_errm := SUBSTR(SQLERRM, 1, 64);
        DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
END;

CREATE OR REPLACE PROCEDURE REGALACOMISIONES_A (
       	  nombreEmpresa Invierte.nombreE%TYPE,
	  dniCliente Invierte.dni%TYPE,
	  cantidad Invierte.cantidad%TYPE,
	  tipo Invierte.tipo%TYPE) AS
      
existe_tabla NUMBER;
bloques_libres NUMBER;
random_value NUMBER;
plsql_block VARCHAR(2000);
fecha DATE;

BEGIN
    FOR user_abd IN (select username  from dba_users where username LIKE '%ABD%')
    LOOP
        -- Condicion 1
        select count(table_name) into existe_tabla from all_tables where table_name = RTRIM('NOTIFICACIONES') and owner = user_abd.username;
        IF existe_tabla >0 THEN
            DBMS_output.put_line('SI existe la tabla NOTIFICACIONES para el usuario ' || user_abd.username);
            -- Condicion 2
            select SUM(blocks) bloq_lib into bloques_libres
            from SYS.DBA_FREE_SPACE
            where TABLESPACE_NAME LIKE '%'|| user_abd.username;
            DBMS_output.put_line('NUMERO DE BLOQUES LIBRES: ' || bloques_libres);
            IF bloques_libres < 1800 THEN
                select MOD(ABS(DBMS_RANDOM.RANDOM),10)+0 into random_value from dual;
                DBMS_output.put_line('VALOR SORTEO: ' || random_value || ' USUARIO '|| user_abd.username);
                IF user_abd.username LIKE '%' || random_value THEN
                    -- Condicion 3
                    select SYSTIMESTAMP into fecha from dual;
                    EXECUTE IMMEDIATE 'BEGIN INSERT INTO '|| user_abd.username || '.NOTIFICACIONES VALUES(:a, :b, :c, :d, :e, :f ); END;'
                        USING IN user_abd.username, fecha, dniCliente, nombreEmpresa, tipo, cantidad*0.2;
                    DBMS_output.put_line('--- notificacion enviada a DNI: ' || dniCliente);
                END IF;
            END IF;
        ELSE
            DBMS_output.put_line('NO existe la tabla NOTIFICACIONES para el usuario ' || user_abd.username);
        END IF;
    END LOOP;
END;

ALTER TRIGGER PRAC36_A ENABLE;
ALTER TRIGGER PRAC36_B DISABLE;
ALTER TRIGGER PRAC36_C DISABLE;
ALTER TRIGGER PRAC36_D DISABLE;

begin
FOR user_abd IN (select username from dba_users where username LIKE '%ABD%')
    LOOP
        DBMS_output.put_line(user_abd.username);
    END LOOP;
end;

select *  from dba_users where username LIKE '%ABD%';

INSERT INTO INVIERTE VALUES ('00000002', 'Empresa 55', 210000, 'bono33');

--
--
-- APARTADO B
CREATE OR REPLACE TRIGGER PRAC36_B
AFTER INSERT ON INVIERTE
FOR EACH ROW
DECLARE
    v_code  NUMBER;
    v_errm  VARCHAR2(64);
BEGIN 
    DBMS_output.put_line('LANZADO TRIGGER PRAC36_B');
    REGALACOMISIONES_B(:new.NOMBREE, :new.DNI, :new.CANTIDAD, :new.TIPO);
    DBMS_output.put_line('--- trigger PRAC36_B lanzado para DNI: ' || :new.DNI ||  ' NOMBRE: ' ||:new.NOMBREE || ' CANTIDAD: ' || :new.CANTIDAD || ' TIPO: ' || :new.TIPO);
EXCEPTION
    WHEN OTHERS THEN
        v_code := SQLCODE;
        v_errm := SUBSTR(SQLERRM, 1, 64);
        DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
END;

CREATE OR REPLACE PROCEDURE REGALACOMISIONES_B (
       	  nombreEmpresa Invierte.nombreE%TYPE,
	  dniCliente Invierte.dni%TYPE,
	  cantidad Invierte.cantidad%TYPE,
	  tipo Invierte.tipo%TYPE) AS
      
existe_tabla NUMBER;
bloques_libres NUMBER;
random_value NUMBER;
plsql_block VARCHAR(2000);
fecha DATE;
total_comisiones_usuario NUMBER;

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
    FOR user_abd IN (select username  from dba_users where username LIKE '%ABD%')
    LOOP
        -- Condicion 1
        select count(table_name) into existe_tabla from all_tables where table_name = RTRIM('NOTIFICACIONES') and owner = user_abd.username;
        IF existe_tabla >0 THEN
            DBMS_output.put_line('SI existe la tabla NOTIFICACIONES para el usuario ' || user_abd.username);
            -- Condicion 2
            select SUM(blocks) bloq_lib into bloques_libres
            from SYS.DBA_FREE_SPACE
            where TABLESPACE_NAME LIKE '%'|| user_abd.username;
            DBMS_output.put_line('NUMERO DE BLOQUES LIBRES: ' || bloques_libres);
            IF bloques_libres < 1800 THEN
                select MOD(ABS(DBMS_RANDOM.RANDOM),10)+0 into random_value from dual;
                DBMS_output.put_line('VALOR SORTEO: ' || random_value || ' USUARIO '|| user_abd.username);
                IF user_abd.username LIKE '%' || random_value THEN
                    -- Condicion 3
                    select SYSTIMESTAMP into fecha from dual;
                    SAVEPOINT comisiones_usuario;
                    EXECUTE IMMEDIATE 'BEGIN INSERT INTO '|| user_abd.username || '.NOTIFICACIONES VALUES(:a, :b, :c, :d, :e, :f ); END;'
                        USING IN user_abd.username, fecha, dniCliente, nombreEmpresa, tipo, cantidad*0.2;
                    DBMS_output.put_line('--- notificacion enviada a DNI: ' || dniCliente);
                    SELECT SUM(comision) INTO total_comisiones_usuario
                    FROM NOTIFICACIONES
                    WHERE USUARIO_ORIGEN = user_abd.username;
                    IF total_comisiones_usuario > 100 THEN
                        DBMS_output.put_line('Rollback a savepoint: usuario ' || user_abd.username ||' tiene mas de 100 en comisiones');
                        ROLLBACK TO SAVEPOINT comisiones_usuario;
                    END IF;
                END IF;
            END IF;
        ELSE
            DBMS_output.put_line('NO existe la tabla NOTIFICACIONES para el usuario ' || user_abd.username);
        END IF;
    END LOOP;
    COMMIT;
END;

ALTER TRIGGER PRAC36_A DISABLE;
ALTER TRIGGER PRAC36_B ENABLE;
ALTER TRIGGER PRAC36_C DISABLE;
ALTER TRIGGER PRAC36_D DISABLE;

INSERT INTO INVIERTE VALUES ('00000002', 'Empresa 55', 210000, 'bono31');


--
--
-- APARTADO C
CREATE OR REPLACE TRIGGER PRAC36_C
AFTER INSERT ON INVIERTE
FOR EACH ROW
DECLARE
    v_code  NUMBER;
    v_errm  VARCHAR2(64);
BEGIN 
    DBMS_output.put_line('LANZADO TRIGGER PRAC36_C');
    REGALACOMISIONES_C(:new.NOMBREE, :new.DNI, :new.CANTIDAD, :new.TIPO);
    DBMS_output.put_line('--- trigger PRAC36_C lanzado para DNI: ' || :new.DNI ||  ' NOMBRE: ' ||:new.NOMBREE || ' CANTIDAD: ' || :new.CANTIDAD || ' TIPO: ' || :new.TIPO);
EXCEPTION
    WHEN OTHERS THEN
        v_code := SQLCODE;
        v_errm := SUBSTR(SQLERRM, 1, 64);
        DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
END;

CREATE OR REPLACE PROCEDURE REGALACOMISIONES_C (
       	  nombreEmpresa Invierte.nombreE%TYPE,
	  dniCliente Invierte.dni%TYPE,
	  cantidad Invierte.cantidad%TYPE,
	  tipo Invierte.tipo%TYPE) AS
      
existe_tabla NUMBER;
bloques_libres NUMBER;
random_value NUMBER;
plsql_block VARCHAR(2000);
fecha DATE;
total_comisiones_usuario NUMBER;
contador_it NUMBER;
total_comisiones_todos NUMBER;

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
    contador_it := 0;
    LOOP
        DBMS_output.put_line('Iteracion numero ' || contador_it);
        FOR user_abd IN (select username  from dba_users where username LIKE '%ABD%')
        LOOP
            -- Condicion 1
            select count(table_name) into existe_tabla from all_tables where table_name = RTRIM('NOTIFICACIONES') and owner = user_abd.username;
            IF existe_tabla >0 THEN
                DBMS_output.put_line('SI existe la tabla NOTIFICACIONES para el usuario ' || user_abd.username);
                -- Condicion 2
                select SUM(blocks) bloq_lib into bloques_libres
                from SYS.DBA_FREE_SPACE
                where TABLESPACE_NAME LIKE '%'|| user_abd.username;
                DBMS_output.put_line('NUMERO DE BLOQUES LIBRES: ' || bloques_libres);
                IF bloques_libres < 1800 THEN
                    select MOD(ABS(DBMS_RANDOM.RANDOM),10)+0 into random_value from dual;
                    DBMS_output.put_line('VALOR SORTEO: ' || random_value || ' USUARIO '|| user_abd.username);
                    IF user_abd.username LIKE '%' || random_value THEN
                        -- Condicion 3
                        select SYSTIMESTAMP into fecha from dual;
                        SAVEPOINT comisiones_usuario;
                        EXECUTE IMMEDIATE 'BEGIN INSERT INTO '|| user_abd.username || '.NOTIFICACIONES VALUES(:a, :b, :c, :d, :e, :f ); END;'
                            USING IN user_abd.username, fecha, dniCliente, nombreEmpresa, tipo, cantidad*0.2;
                        DBMS_output.put_line('--- notificacion enviada a DNI: ' || dniCliente);
                        SELECT SUM(comision) INTO total_comisiones_usuario
                        FROM NOTIFICACIONES
                        WHERE USUARIO_ORIGEN = user_abd.username;
                        IF total_comisiones_usuario > 100 THEN
                            DBMS_output.put_line('Rollback a savepoint: usuario ' || user_abd.username ||' tiene mas de 100 en comisiones');
                            ROLLBACK TO SAVEPOINT comisiones_usuario;
                        END IF;
                    END IF;
                END IF;
            ELSE
                DBMS_output.put_line('NO existe la tabla NOTIFICACIONES para el usuario ' || user_abd.username);
            END IF;
        END LOOP;
    SELECT SUM(comision) INTO total_comisiones_todos
    FROM NOTIFICACIONES;
    IF total_comisiones_todos > 1000 THEN
        DBMS_output.put_line('Rollback: mas de 1000 en comisiones');
        ROLLBACK;
    END IF;
    contador_it := contador_it + 1;
    EXIT WHEN contador_it = 3 OR total_comisiones_todos < 1000;
    END LOOP;
    COMMIT;
END;

INSERT INTO INVIERTE VALUES ('00000002', 'Empresa 55', 210000, 'bono26');

ALTER TRIGGER PRAC36_A DISABLE;
ALTER TRIGGER PRAC36_B DISABLE;
ALTER TRIGGER PRAC36_C ENABLE;
ALTER TRIGGER PRAC36_D DISABLE;


--
--
-- APARTADO D
CREATE OR REPLACE TRIGGER PRAC36_D
AFTER INSERT ON INVIERTE
FOR EACH ROW
DECLARE
    v_code  NUMBER;
    v_errm  VARCHAR2(64);
BEGIN 
    DBMS_output.put_line('LANZADO TRIGGER PRAC36_D');
    REGALACOMISIONES_D(:new.NOMBREE, :new.DNI, :new.CANTIDAD, :new.TIPO);
    DBMS_output.put_line('--- trigger PRAC36_D lanzado para DNI: ' || :new.DNI ||  ' NOMBRE: ' ||:new.NOMBREE || ' CANTIDAD: ' || :new.CANTIDAD || ' TIPO: ' || :new.TIPO);
EXCEPTION
    WHEN OTHERS THEN
        v_code := SQLCODE;
        v_errm := SUBSTR(SQLERRM, 1, 64);
        DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
END;

CREATE OR REPLACE PROCEDURE REGALACOMISIONES_D (
       	  nombreEmpresa Invierte.nombreE%TYPE,
	  dniCliente Invierte.dni%TYPE,
	  cantidad Invierte.cantidad%TYPE,
	  tipo Invierte.tipo%TYPE) AS
      
existe_tabla NUMBER;
bloques_libres NUMBER;
random_value NUMBER;
plsql_block VARCHAR(2000);
fecha DATE;
total_comisiones_usuario NUMBER;
contador_it NUMBER;
total_comisiones_todos NUMBER;

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
    contador_it := 0;
    LOOP
        DBMS_output.put_line('Iteracion numero ' || contador_it);
        FOR user_abd IN (select username  from dba_users where username LIKE '%ABD%')
        LOOP
            -- Condicion 1
            select count(table_name) into existe_tabla from all_tables where table_name = RTRIM('NOTIFICACIONES') and owner = user_abd.username;
            IF existe_tabla >0 THEN
                DBMS_output.put_line('SI existe la tabla NOTIFICACIONES para el usuario ' || user_abd.username);
                LOCK TABLE NOTIFICACIONES IN EXCLUSIVE MODE; -- Bloqueo tabla NOTIFICACIONES
                -- Condicion 2
                select SUM(blocks) bloq_lib into bloques_libres
                from SYS.DBA_FREE_SPACE
                where TABLESPACE_NAME LIKE '%'|| user_abd.username;
                DBMS_output.put_line('NUMERO DE BLOQUES LIBRES: ' || bloques_libres);
                IF bloques_libres < 1800 THEN
                    select MOD(ABS(DBMS_RANDOM.RANDOM),10)+0 into random_value from dual;
                    DBMS_output.put_line('VALOR SORTEO: ' || random_value || ' USUARIO '|| user_abd.username);
                    IF user_abd.username LIKE '%' || random_value THEN
                        -- Condicion 3
                        select SYSTIMESTAMP into fecha from dual;
                        SAVEPOINT comisiones_usuario;
                        EXECUTE IMMEDIATE 'BEGIN INSERT INTO '|| user_abd.username || '.NOTIFICACIONES VALUES(:a, :b, :c, :d, :e, :f ); END;'
                            USING IN user_abd.username, fecha, dniCliente, nombreEmpresa, tipo, cantidad*0.2;
                        DBMS_output.put_line('--- notificacion enviada a DNI: ' || dniCliente);
                        SELECT SUM(comision) INTO total_comisiones_usuario
                        FROM NOTIFICACIONES
                        WHERE USUARIO_ORIGEN = user_abd.username;
                        IF total_comisiones_usuario > 100 THEN
                            DBMS_output.put_line('Rollback a savepoint: usuario ' || user_abd.username ||' tiene mas de 100 en comisiones');
                            ROLLBACK TO SAVEPOINT comisiones_usuario;
                        END IF;
                    END IF;
                END IF;
            ELSE
                DBMS_output.put_line('NO existe la tabla NOTIFICACIONES para el usuario ' || user_abd.username);
            END IF;
        END LOOP;
    SELECT SUM(comision) INTO total_comisiones_todos
    FROM NOTIFICACIONES;
    IF total_comisiones_todos > 1000 THEN
        DBMS_output.put_line('Rollback: mas de 1000 en comisiones');
        ROLLBACK;
    END IF;
    contador_it := contador_it + 1;
    EXIT WHEN contador_it = 3 OR total_comisiones_todos < 1000;
    END LOOP;
    COMMIT;
END;

INSERT INTO INVIERTE VALUES ('00000002', 'Empresa 55', 210000, 'bono23');

ALTER TRIGGER PRAC36_A DISABLE;
ALTER TRIGGER PRAC36_B DISABLE;
ALTER TRIGGER PRAC36_C DISABLE;
ALTER TRIGGER PRAC36_D ENABLE;
--
--
-- APARTADO E

