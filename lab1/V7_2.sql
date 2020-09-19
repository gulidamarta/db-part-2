USE AdventureWorks2012;
GO

/*
Display on the screen amount of departments, which belongs to the group 'Executive General and Administration'
*/

SELECT COUNT([DepartmentID]) as DepartmentCount FROM HumanResources.Department WHERE [GroupName] = 'Executive General and Administration';
GO

/*
Display on the screen 5 (five) the youngest employees.
*/
SELECT TOP 5 [BusinessEntityID], [JobTitle], [Gender], [BirthDate] FROM HumanResources.Employee 
ORDER BY [BirthDate] DESC;
GO

/*
Display a list of female employees hired on Tuesday.
In the [LoginID] field, replace the ‘adventure-works’ domain with ‘adventure-works2012’
*/ 
SELECT [BusinessEntityID], [JobTitle], [Gender], [HireDate], 
REPLACE([LoginID], 'adventure-works', 'adventure-works2012') 
FROM HumanResources.Employee
WHERE [Gender] = 'F' and DATEPART(DW, [HireDate]) % 7 = 3;
GO