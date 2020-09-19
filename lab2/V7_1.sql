USE AdventureWorks2012;

/*
Display the last hourly rate change date for each employee.
*/
SELECT Employee.[BusinessEntityID], Employee.[JobTitle], MAX(EmployeePayHistory.[RateChangeDate]) AS LastRateDate 
	FROM HumanResources.Employee as Employee 
	INNER JOIN HumanResources.EmployeePayHistory as EmployeePayHistory 
		ON EmployeePayHistory.[BusinessEntityID] = Employee.[BusinessEntityID]
	GROUP BY Employee.[BusinessEntityID], Employee.[JobTitle];

/*
Display the number of years that each employee has worked in each department.
If an employee works in the department up to the present, count the number of years until today.
*/
SELECT Employee.[BusinessEntityID], 
	Employee.[JobTitle], 
	Department.[Name] AS DepName,
	EmployeeDepartmentHistory.[StartDate], 
	EmployeeDepartmentHistory.[EndDate],
	DATEDIFF(YY, EmployeeDepartmentHistory.[StartDate], ISNULL(EmployeeDepartmentHistory.[EndDate], GETDATE())) AS Years
	FROM HumanResources.Employee AS Employee
	INNER JOIN HumanResources.EmployeeDepartmentHistory AS EmployeeDepartmentHistory
		ON Employee.[BusinessEntityID] = EmployeeDepartmentHistory.[BusinessEntityID]
	INNER JOIN HumanResources.Department AS Department
		ON Department.[DepartmentID] = EmployeeDepartmentHistory.[DepartmentID];

/*
Display information about all employees, indicating the department in which they currently work.
Also deduce the first word from the name of the department group.
*/
SELECT Employee.[BusinessEntityID],
	Employee.[JobTitle],
	Department.[Name] AS DepName,
	Department.[DepartmentID],
	Department.[GroupName],
	CASE 
		WHEN CHARINDEX(' ', Department.[GroupName]) > 0 
			THEN LEFT(Department.[GroupName], CHARINDEX(' ', Department.[GroupName]) -1)
		ELSE Department.[GroupName]
		END
		AS DepGroup
	FROM HumanResources.Employee as Employee
	INNER JOIN HumanResources.EmployeeDepartmentHistory AS EmployeeDepartmentHistory
		ON EmployeeDepartmentHistory.[BusinessEntityID] = Employee.[BusinessEntityID]
	INNER JOIN HumanResources.Department as Department
		ON Department.[DepartmentID] = EmployeeDepartmentHistory.[DepartmentID] 
		AND EmployeeDepartmentHistory.[EndDate] IS NULL;
