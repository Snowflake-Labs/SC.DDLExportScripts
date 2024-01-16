CREATE TABLE Employee (
        EmployeeID INT NOT NULL,
        FirstName VARCHAR(50),
        LastName VARCHAR(50),
        Department VARCHAR(50),
        Email VARCHAR(100),
        Salary number,
        PRIMARY KEY (EmployeeID)
);

CREATE TABLE salary_log(
    type_user VARCHAR(50),
    id INT,
    old_salary number,
    new_salary number
);

CREATE TABLE expandOnTable
(
    id INTEGER,
    pd PERIOD ( TIMESTAMP)
);

CREATE TABLE SC_EXAMPLE_DEMO_2.project
(
    emp_id       INTEGER,
    project_name VARCHAR(20),
    dept_id      INTEGER,
    duration     PERIOD( DATE)
);

CREATE TABLE MessageStorage
(
    MessageID TIMESTAMP(0),
    Message1 VARCHAR(100),
    Message2 VARCHAR(100)
);

CREATE TABLE account_balance
(
    account_id INTEGER NOT NULL,
    month_id   INTEGER,
    balance    INTEGER
) UNIQUE PRIMARY INDEX (account_id, month_id);


CREATE TABLE ResTable
(
    Column1 VARCHAR(255)
);

CREATE TABLE EMPLOYEE_JOB_PERIODS (
    FIRST_NAME VARCHAR(100),
    LAST_NAME VARCHAR(100),
    JOB_DURATION PERIOD(DATE)
);

CREATE TABLE vEmployee
(
    PersonID  INT,
    LastName  VARCHAR(255),
    FirstName VARCHAR(255)
);