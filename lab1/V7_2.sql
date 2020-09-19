USE AdventureWorks2012;
GO

/*
Вывести на экран количество отделов, которые входят в группу 'Executive General and Administration'
*/

SELECT COUNT([DepartmentID]) as DepartmentCount FROM HumanResources.Department WHERE [GroupName] = 'Executive General and Administration';
GO

/*
Вывести на экран 5(пять) самых молодых сотрудников.
*/
SELECT TOP 5 [BusinessEntityID], [JobTitle], [Gender], [BirthDate] FROM HumanResources.Employee 
ORDER BY [BirthDate] DESC;
GO

/*
Вывести на экран список сотрудников женского пола, принятых на работу во вторник (Tuesday). 
В поле [LoginID] заменить домен ‘adventure-works’ на ‘adventure-works2012’
*/ 
SELECT [BusinessEntityID], [JobTitle], [Gender], [HireDate], 
REPLACE([LoginID], 'adventure-works', 'adventure-works2012') 
FROM HumanResources.Employee
WHERE [Gender] = 'F' and DATEPART(DW, [HireDate]) % 7 = 3;
GO