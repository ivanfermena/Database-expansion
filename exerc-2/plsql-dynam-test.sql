
SET SERVEROUTPUT ON SIZE 100000;

INSERT INTO Empresa VALUES ('Empresa11', 111111, 110000.00);
INSERT INTO Empresa VALUES ('Empresa22', 222222, 220000.00);
INSERT INTO Empresa VALUES ('Empresa100', 333333, 330000.00);


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