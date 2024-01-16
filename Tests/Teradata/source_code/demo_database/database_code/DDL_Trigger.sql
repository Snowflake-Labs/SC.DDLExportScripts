
CREATE TRIGGER RaiseTrig
  AFTER UPDATE OF salary ON employee
  REFERENCING OLD AS OldRow NEW AS NewRow
  FOR EACH ROW
    WHEN ((NewRow.salary - OldRow.salary) / OldRow.salary >.10)
    INSERT INTO salary_log
    VALUES ('USER', NewRow.EmployeeID, OldRow.salary, NewRow.salary);