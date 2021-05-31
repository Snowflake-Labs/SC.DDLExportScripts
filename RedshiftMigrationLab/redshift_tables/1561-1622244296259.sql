create view vw_test as 
select ddl from v_generate_tbl_ddl 
where tablename='date';