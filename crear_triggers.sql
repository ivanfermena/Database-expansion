create or replace PROCEDURE crear_triggers AS
  plsql_block VARCHAR2(2000);

-- para excepcion 
      Tcoderror NUMBER;
      Ttexterror VARCHAR2(100);

BEGIN
  
  FOR emp_name IN (select REPLACE(table_name, 'INVERSIONES_', '') from tabs WHERE table_name LIKE 'INVERSIONES_%')
  LOOP        
         plsql_block := 'CREATE OR REPLACE TRIGGER trig_suma_' || REPLACE(emp_name, ' ', '') || '
    after insert ON INVERSIONES_' || REPLACE(emp_name, ' ', '') || ' FOR EACH ROW
    Declare
        estaCreada INT;
    Begin
        select COUNT(*) into estaCreada
        from SUMAEMPRESA
        where nombreE = ' || REPLACE(emp_name, ' ', '')  || '; 
        
        IF estaCreada = 0 THEN
            update SUMAEMPRESA 
            set Cantidad = Cantidad + :new.Cantidad
            where nombreE = ' || REPLACE(emp_name, ' ', '') || ' ;
        ELSE
            insert into SUMAEMPRESA values (' || REPLACE(emp_name, ' ', '') || ', :new.Cantidad);
        END IF;
    end';
    
       DBMS_OUTPUT.PUT_LINE(plsql_block);
       EXECUTE IMMEDIATE plsql_block;
        DBMS_OUTPUT.PUT_LINE('Se ha creado un nuevo trigger con nombre trig_suma_' || emp_name);
  END LOOP;



EXCEPTION

  WHEN OTHERS THEN
	Tcoderror:= SQLCODE;
	Ttexterror:= SUBSTR(SQLERRM,1, 100);
   DBMS_output.put_line('Sale por una excepcion: ' || Tcoderror ||   '  -- ' || Ttexterror );
   DBMS_output.put_line('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$' ); 

END;


