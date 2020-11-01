USE AdventureWorks2012;
GO

/*
1. Создайте scalar-valued функцию, которая будет принимать в качестве входного параметра код валюты (Sales.Currency.CurrencyCode) 
и возвращать последний установленный курс по отношению к USD (Sales.CurrencyRate.ToCurrencyCode).
*/
IF OBJECT_ID (N'Sales.ufnGetLastCurrencyRateToUSD', N'FN') IS NOT NULL  
    DROP FUNCTION Sales.ufnGetLastCurrencyRateToUSD;  
GO 


CREATE FUNCTION Sales.ufnGetLastCurrencyRateToUSD(@CurrencyCode NCHAR(3))
	RETURNS MONEY AS
BEGIN
	DECLARE @LastSetCurrencyRate DATETIME
	DECLARE @LastCurrencyRate MONEY
	
	SELECT @LastSetCurrencyRate = MAX(CurrencyRateDate)
	FROM Sales.CurrencyRate 
		WHERE FromCurrencyCode = N'USD' AND ToCurrencyCode = @CurrencyCode

	SELECT @LastCurrencyRate = EndOfDayRate
	FROM Sales.CurrencyRate
		WHERE FromCurrencyCode = N'USD' AND ToCurrencyCode = @CurrencyCode AND CurrencyRateDate = @LastSetCurrencyRate

	RETURN @LastCurrencyRate;
END
GO

-- Проверка работоспособности функции
PRINT(Sales.ufnGetLastCurrencyRateToUSD(N'EUR'));
GO

-- Выборка для проверки корректного результата функции
SELECT * FROM Sales.CurrencyRate
	WHERE FromCurrencyCode = N'USD' AND ToCurrencyCode = N'EUR'
		ORDER BY CurrencyRateDate DESC;
GO

/*
2. Создайте inline table-valued функцию, которая будет принимать в качестве входного параметра id продукта (Production.Product.ProductID), 
а возвращать детали заказа на покупку данного продукта из Purchasing.PurchaseOrderDetail, где количество заказанных позиций более 1000 (OrderQty).
*/
IF OBJECT_ID (N'Purchasing.ufn_GetOrderDetails', N'IF') IS NOT NULL  
    DROP FUNCTION Purchasing.ufn_GetOrderDetails;  
GO 

CREATE FUNCTION Purchasing.ufn_GetOrderDetails(@ProductID INT)
RETURNS TABLE 
AS 
RETURN
(
	SELECT * FROM Purchasing.PurchaseOrderDetail
		WHERE ProductID = @ProductID AND OrderQty > 1000
)
GO

-- Тестовый вывод для сравнения результатов с результатами работы функции
SELECT * FROM Purchasing.PurchaseOrderDetail
	WHERE ProductID = 865;
GO


SELECT * FROM Purchasing.ufn_GetOrderDetails(865);
GO

/*
3. Вызовите функцию для каждого продукта, применив оператор CROSS APPLY. 
Вызовите функцию для каждого продукта, применив оператор OUTER APPLY.
*/

-- CROSS APPLY
SELECT
	Product.ProductID,
	Product.Name,
	PurchaseOrderID,
	OrderQty
FROM Production.Product Product
	CROSS APPLY Purchasing.ufn_GetOrderDetails(Product.ProductID);
GO

-- OUTER APPLY
SELECT 
	Product.ProductID,
	Product.Name,
	PurchaseOrderID,
	OrderQty
FROM Production.Product Product
	OUTER APPLY Purchasing.ufn_GetOrderDetails(Product.ProductID);
GO


/*
4. Измените созданную inline table-valued функцию, сделав ее multistatement table-valued 
(предварительно сохранив для проверки код создания inline table-valued функции).
*/
IF OBJECT_ID (N'Purchasing.ufn_GetMultiOrderDetails') IS NOT NULL  
    DROP FUNCTION Purchasing.ufn_GetMultiOrderDetails;  
GO 

CREATE FUNCTION Purchasing.ufn_GetMultiOrderDetails(@ProductID INT)
RETURNS @OrderDetailTable TABLE(
	PurchaseOrderID INT,
	PurchaseOrderDetailID INT,
	DueDate DATETIME,
	OrderQty SMALLINT,
	ProductID INT,
	UnitPrice MONEY,
	LineTotal MONEY,
	RecievedQty DECIMAL(8, 2),
	RejectedQty DECIMAL(8, 2),
	StockedQty DECIMAL(9, 2),
	ModifiedDate DATETIME
)
AS
BEGIN
	INSERT INTO @OrderDetailTable
		SELECT
			PurchaseOrderID,
			PurchaseOrderDetailID,
			DueDate,
			OrderQty,
			ProductID,
			UnitPrice,
			LineTotal,
			ReceivedQty,
			RejectedQty,
			StockedQty,
			ModifiedDate
		FROM Purchasing.PurchaseOrderDetail
			WHERE ProductID = @ProductID AND OrderQty > 1000;
		RETURN
END
GO

-- Проверка работы  multistatement table-valued функции
SELECT * FROM Purchasing.ufn_GetMultiOrderDetails(865);
GO

-- Проверка работы inline table-valued функци
SELECT * FROM Purchasing.ufn_GetOrderDetails(865);
GO