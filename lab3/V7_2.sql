USE AdventureWorks2012;
GO

/*
a) Добавьте в таблицу dbo.PersonPhone поля OrdersCount INT и CardType NVARCHAR(50). 
Также создайте в таблице вычисляемое поле IsSuperior, которое будет хранить 1, если тип карты ‘SuperiorCard’ и 0 для остальных карт.
*/
ALTER TABLE dbo.PersonPhone
	ADD 
		[OrdersCount] INT, 
		[CardType] NVARCHAR(50),
		[IsSuperior] AS 
		CASE
			WHEN [CardType] = 'SuperiorCard' THEN 1
			ELSE 0
		END;
GO

SELECT * FROM dbo.PersonPhone;
GO

/*
b) создайте временную таблицу #PersonPhone, с первичным ключом по полю BusinessEntityID. 
Временная таблица должна включать все поля таблицы dbo.PersonPhone за исключением поля IsSuperior.
*/
CREATE TABLE #PersonPhone(
	[BusinessEntityId] INT NOT NULL,
	[PhoneNumber] NVARCHAR(25) NOT NULL,
	[PhoneNumberTypeId] BIGINT,
	[ModifiedDate] DATETIME NOT NULL,
	[PostalCode] NVARCHAR(15),
	[OrdersCount] INT,
	[CardType] NVARCHAR(50)
);
GO

ALTER TABLE #PersonPhone
	ADD CONSTRAINT PK_PersonPhones_BusinessEntityID 
	PRIMARY KEY ([BusinessEntityID]);
GO

SELECT * FROM #PersonPhone;
GO

/*
c) Заполните временную таблицу данными из dbo.PersonPhone. Поле CardType заполните данными из таблицы Sales.CreditCard. 
Посчитайте количество заказов, оплаченных каждой картой (CreditCardID) в таблице Sales.SalesOrderHeader и заполните этими значениями поле OrdersCount. 
Подсчет количества заказов осуществите в Common Table Expression (CTE).
*/

-- Определение Common Table Expression (CTE) для подсчета количества заказов
WITH SalesCount_CTE([CreditCardID], [OrdersCount]) AS
(
	SELECT SalesOrderHeader.[CreditCardID], COUNT(SalesOrderHeader.[CreditCardID]) AS OrdersCount
	FROM Sales.SalesOrderHeader AS SalesOrderHeader
	GROUP BY SalesOrderHeader.[CreditCardID]
)

INSERT INTO #PersonPhone(
	[BusinessEntityID],
	[PhoneNumber],
	[PhoneNumberTypeID],
	[ModifiedDate],
	[PostalCode],
	[OrdersCount],
	[CardType]
)
SELECT 
	PersonPhone.[BusinessEntityID],
	PersonPhone.[PhoneNumber],
	PersonPhone.[PhoneNumberTypeID],
	PersonPhone.[ModifiedDate],
	PersonPhone.[PostalCode],
	SalesCount_CTE.[OrdersCount],
	Sales.CreditCard.[CardType]
FROM dbo.PersonPhone AS PersonPhone
LEFT JOIN Sales.PersonCreditCard
	ON PersonPhone.[BusinessEntityID] = Sales.PersonCreditCard.[BusinessEntityID]
LEFT JOIN Sales.CreditCard
	ON Sales.PersonCreditCard.[CreditCardID] = Sales.CreditCard.[CreditCardID]
LEFT JOIN SalesCount_CTE
	ON Sales.CreditCard.[CreditCardID] = SalesCount_CTE.[CreditCardID];
GO

-- Выборка данных из временной таблицы для проверки корректности записи данных в нее
SELECT * FROM #PersonPhone;
GO

-- Проверка корректности выборки данных из таблицы dbo.PersonPhone
SELECT * FROM dbo.PersonPhone 
	WHERE [BusinessEntityID] = 3730;
GO

-- Вывод строки бд, в которой есть соотвествие BusinessEntityID на CreditCardID
SELECT * FROM Sales.PersonCreditCard
	WHERE [BusinessEntityID] = 3730;
GO

-- Все заказы, оплаченные картой с CreditCardID = 3092
SELECT * FROM Sales.SalesOrderHeader
	WHERE [CreditCardID] = 3092;
GO

-- Данные о карте по её идентификатору
SELECT * FROM Sales.CreditCard
WHERE [CreditCardID] = 3092;
GO

/*
d) удалите из таблицы dbo.PersonPhone одну строку (где BusinessEntityID = 297)
*/
SELECT * FROM dbo.PersonPhone
	WHERE [BusinessEntityID] = 297;
GO

DELETE FROM dbo.PersonPhone
	WHERE [BusinessEntityID] = 297;
GO

SELECT * FROM #PersonPhone;
GO

/*
e) напишите Merge выражение, использующее dbo.PersonPhone как target, а временную таблицу как source. 
Для связи target и source используйте BusinessEntityID. Обновите поля OrdersCount и CardType, если запись присутствует в source и target. 
Если строка присутствует во временной таблице, но не существует в target, добавьте строку в dbo.PersonPhone. 
Если в dbo.PersonPhone присутствует такая строка, которой не существует во временной таблице, удалите строку из dbo.PersonPhone.
*/
INSERT INTO dbo.PersonPhone(
	[BusinessEntityID],
	[PhoneNumber],
	[ModifiedDate],
	[PostalCode]
)
VALUES (
	99999999,
	'111-111-111',
	CURRENT_TIMESTAMP,
	'220034'
);
GO

SELECT * FROM dbo.PersonPhone
	WHERE [BusinessEntityID] = 99999999;
GO


MERGE INTO dbo.PersonPhone AS [target]
USING #PersonPhone AS [source]
ON [target].[BusinessEntityID] = [source].[BusinessEntityID]
WHEN MATCHED THEN
    UPDATE
    SET [OrdersCount] = [source].[OrdersCount],
        [CardType]    = [source].[CardType]
WHEN NOT MATCHED BY TARGET THEN
    INSERT (
		[BusinessEntityID],
		[PhoneNumber],
		[PhoneNumberTypeID],
		[ModifiedDate],
		[PostalCode],
		[OrdersCount],
		[CardType]
	)
    VALUES (	
		[source].[BusinessEntityID],
		[source].[PhoneNumber],
		[source].[PhoneNumberTypeID],
		[source].[ModifiedDate],
		[source].[PostalCode],
		[source].[OrdersCount],
		[source].[CardType]
	)
WHEN NOT MATCHED BY SOURCE THEN DELETE;
GO

-- Проверка того, что после merge операции в таблице dbo.PersonPhone вновь появилась запись с BusinessEntityId = 297 
-- и запись с BusinessEntityId = 99999999 удалена
SELECT * FROM  dbo.PersonPhone
	WHERE [BusinessEntityID] = 297 OR [BusinessEntityID] = 99999999;
GO

