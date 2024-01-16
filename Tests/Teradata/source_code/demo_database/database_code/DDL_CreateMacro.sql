CREATE MACRO Get_Emp AS ( 
SELECT EmployeeID,FirstName,LastName
FROM Employee;
);


CREATE MACRO Get_Emp_version2 AS ( 
SELECT EmployeeID,FirstName,LastName
FROM Employee;
);