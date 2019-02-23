CREATE TABLESPACE ESPABD0302 DATAFILE 'ESPABD0302' SIZE 16M
AUTOEXTEND OFF;

CREATE USER ABD0302 IDENTIFIED BY USERABD19 DEFAULT
TABLESPACE ESPABD0302 TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON
ESPABD0302; 

GRANT create table, delete any table, select any dictionary ,
connect, create session , create synonym , create public synonym ,
create sequence, create view , create trigger TO ABD0302; 

GRANT create procedure, alter any procedure, drop any procedure,
execute any procedure TO ABD0302; 

GRANT create trigger, alter any trigger, drop any trigger TO
ABD0302; 

SET AUTOCOMMIT ON;

SET SERVEROUTPUT ON SIZE 100000;





