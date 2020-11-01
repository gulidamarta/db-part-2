USE AdventureWorks2012;
GO

/*
Создайте хранимую процедуру, которая будет возвращать сводную таблицу (оператор PIVOT), 
отображающую данные о количестве сотрудников (HumanResources.Employee) работающих в определенную смену (HumanResources.Shift). 
Вывести информацию необходимо для каждого отдела (HumanResources.Department). 

Список названий смен передайте в процедуру через входной параметр.
*/

IF OBJECT_ID (N'dbo.uspGetEmpCountByShift') IS NOT NULL  
    DROP PROCEDURE dbo.uspGetEmpCountByShift;  
GO 

CREATE PROCEDURE dbo.uspGetEmpCountByShift (@Shifts NVARCHAR(MAX))
AS
	DECLARE @sql NVARCHAR(MAX) = ''
BEGIN
		SET @sql = '
		SELECT * FROM (
			SELECT 
				Employee.BusinessEntityID, 
				Department.Name AS DepName,
				HumarResourcesShift.Name AS ShiftName
			FROM HumanResources.EmployeeDepartmentHistory AS EmployeeDepartmentHistory
				INNER JOIN HumanResources.Employee AS Employee
					ON EmployeeDepartmentHistory.BusinessEntityID = Employee.BusinessEntityID
				INNER JOIN HumanResources.Department AS Department 
					ON EmployeeDepartmentHistory.DepartmentID = Department.DepartmentID
				INNER JOIN HumanResources.Shift AS HumarResourcesShift
					ON EmployeeDepartmentHistory.ShiftID = HumarResourcesShift.ShiftID
						WHERE EmployeeDepartmentHistory.EndDate IS NULL
		) AS DepShiftTable
		PIVOT (
			COUNT(BusinessEntityID) FOR ShiftName IN ('+ @Shifts + ')
		) AS EmpCountShiftTable;
		'
	EXECUTE sp_executesql @sql;
END
GO

-- Вызов хранимой процедуры
EXECUTE dbo.uspGetEmpCountByShift '[Day],[Evening],[Night]';


-- Проверка работоспособности запроса, используемого в хранимой процедуре
SELECT 
	Employee.BusinessEntityID, 
	Department.Name AS DepName,
	HumarResourcesShift.Name AS ShiftName
FROM HumanResources.EmployeeDepartmentHistory AS EmployeeDepartmentHistory
	INNER JOIN HumanResources.Employee AS Employee
		ON EmployeeDepartmentHistory.BusinessEntityID = Employee.BusinessEntityID
	INNER JOIN HumanResources.Department AS Department 
		ON EmployeeDepartmentHistory.DepartmentID = Department.DepartmentID
	INNER JOIN HumanResources.Shift AS HumarResourcesShift
		ON EmployeeDepartmentHistory.ShiftID = HumarResourcesShift.ShiftID
			WHERE EmployeeDepartmentHistory.EndDate IS NULL;
GO

