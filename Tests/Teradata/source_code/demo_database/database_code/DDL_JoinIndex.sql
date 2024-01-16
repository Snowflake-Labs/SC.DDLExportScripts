CREATE JOIN INDEX Employee_JI 
AS 
SELECT EmployeeID,FirstName,LastName
FROM Employee 
PRIMARY INDEX(FirstName);



CREATE JOIN INDEX Employee_JI2
AS 
SELECT EmployeeID,FirstName,LastName
FROM Employee 
PRIMARY INDEX(LastName);