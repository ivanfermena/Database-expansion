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

CREATE OR REPLACE TRIGGER PRAC36
AFTER INSERT ON INVIERTE
FOR EACH ROW
BEGIN 
    REGALACOMISIONES(:new.NOMBREE, :new.DNI, :new.CANTIDAD, :new.TIPO);
    DBMS_output.put_line('--- trigger lanzado para DNI: ' || :new.DNI ||  ' NOMBRE: ' ||:new.NOMBREE || ' CANTIDAD: ' || :new.CANTIDAD || ' TIPO: ' || :new.TIPO);
END;

CREATE OR REPLACE PROCEDURE REGALACOMISIONES (
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
            -- Condicion 2
            select SUM(blocks) bloq_lib into bloques_libres
            from SYS.DBA_FREE_SPACE
            where TABLESPACE_NAME LIKE '%'|| user_abd.username
            group by TABLESPACE_NAME, FILE_ID
            order by bloq_lib;
            DBMS_output.put_line('NUMERO DE BLOQUES LIBRES: ' || bloques_libres);
            IF bloques_libres > 1800 THEN
                select MOD(ABS(DBMS_RANDOM.RANDOM),10)+0 into random_value from dual;
                DBMS_output.put_line('VALOR SORTEO: ' || random_value || ' USUARIO '|| user_abd.username);
                IF user_abd.username LIKE '%' || random_value THEN
                    -- Condicion 3
                    select SYSTIMESTAMP into fecha from dual;
                    INSERT INTO NOTIFICACIONES VALUES(user_abd.username, fecha, dniCliente, nombreEmpresa, tipo, cantidad*0.2 );
                    DBMS_output.put_line('--- notificacion enviada a DNI: ' || dniCliente);
                END IF;
            END IF;
        ELSE
            DBMS_output.put_line('No existe la tabla NOTIFICACIONES para el usuario ' || user_abd.username);
        END IF;
    END LOOP;
END;

begin
FOR user_abd IN (select username from dba_users where username LIKE '%ABD%')
    LOOP
        DBMS_output.put_line(user_abd.username);
    END LOOP;
end;

select *  from dba_users where username LIKE '%ABD%';

INSERT INTO INVIERTE VALUES ('00000002', 'Empresa 55', 210000, 'bono18');


