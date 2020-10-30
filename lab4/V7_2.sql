USE AdventureWorks2012;
GO

/*
a) Создайте представление VIEW, отображающее данные из таблиц Sales.Currency и Sales.CurrencyRate. 
Таблица Sales.Currency должна отображать название валюты для поля ToCurrencyCode. 
Создайте уникальный кластерный индекс в представлении по полю CurrencyRateID.
*/
-- Проверка того, что представление еще не создано (в случае его присуствия -- удаление)
IF OBJECT_ID ('Sales.vCurrencyRate') IS NOT NULL
BEGIN
    DROP VIEW Sales.vCurrencyRate;
END
GO


CREATE VIEW Sales.vCurrencyRate
WITH SCHEMABINDING
AS
SELECT 
	currencyRate.[CurrencyRateID],
	currencyRate.[CurrencyRateDate],
	currencyRate.[FromCurrencyCode],
	currency.[Name],
	currency.[CurrencyCode],
	currencyRate.[AverageRate],
	currencyRate.[EndOfDayRate]
FROM Sales.Currency AS currency
INNER JOIN Sales.CurrencyRate AS currencyRate
	ON currency.[CurrencyCode] = currencyRate.[ToCurrencyCode]
GO

CREATE UNIQUE CLUSTERED INDEX IX_CurrencyRateID
	ON Sales.vCurrencyRate ([CurrencyRateID])
GO


/*
b) Создайте один INSTEAD OF триггер для представления на три операции INSERT, UPDATE, DELETE. 
Триггер должен выполнять соответствующие операции в таблицах Sales.Currency и Sales.CurrencyRate.
*/
-- Проверка того, что данный триггер еще не создан (в случае его присуствия -- его удаление)
IF OBJECT_ID ('Sales.InsteadvCurrencyRateTrigger') IS NOT NULL
BEGIN
    DROP TRIGGER Sales.InsteadvCurrencyRateTrigger;
END
GO


CREATE TRIGGER Sales.InsteadvCurrencyRateTrigger ON Sales.vCurrencyRate
	INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @currencyCode NVARCHAR(50);
	
	-- UPDATE
	IF ( EXISTS ( SELECT 1 FROM INSERTED ))
            AND ( EXISTS ( SELECT 1 FROM DELETED ))
		BEGIN
			UPDATE Sales.Currency
			SET 
				[Name] = inserted.[Name],
				[ModifiedDate] = GETDATE()
			FROM Sales.Currency AS currencies
			JOIN inserted ON inserted.[CurrencyCode] = currencies.[CurrencyCode]

			UPDATE Sales.CurrencyRate
			SET 
				[CurrencyRateDate] = inserted.CurrencyRateDate,
				[AverageRate] = inserted.AverageRate,
				[EndOfDayRate] = inserted.EndOfDayRate,
				[ModifiedDate] = GETDATE()
			FROM Sales.CurrencyRate AS currencyRates
			JOIN inserted ON inserted.[CurrencyRateID] = currencyRates.[CurrencyRateID]
		END;
	 -- INSERT
	 ELSE IF ( EXISTS ( SELECT 1 FROM INSERTED ))
		BEGIN
			IF NOT EXISTS (
				SELECT * 
				FROM Sales.Currency AS sc 
				JOIN inserted ON inserted.[CurrencyCode] = sc.[CurrencyCode])
			BEGIN
				INSERT INTO Sales.Currency (
					[CurrencyCode],
					[Name],
					[ModifiedDate])
				SELECT 
					[CurrencyCode],
					[Name],
					GETDATE()
				FROM inserted
			END
			ELSE
				UPDATE
				    Sales.Currency
				SET
				    [Name] = inserted.[Name],
				    [ModifiedDate] = GETDATE()
				FROM
				    inserted
				WHERE
				    Currency.[CurrencyCode] = inserted.[CurrencyCode]

			INSERT INTO Sales.CurrencyRate(
				[CurrencyRateDate],
				[FromCurrencyCode],
				[ToCurrencyCode],
				[AverageRate],
				[EndOfDayRate],
				[ModifiedDate])
			SELECT 
				[CurrencyRateDate],
				[FromCurrencyCode],
				[CurrencyCode],
				[AverageRate],
				[EndOfDayRate],
				GETDATE()
			FROM inserted
		END;
		-- DELETE
		ELSE IF ( EXISTS ( SELECT 1 FROM DELETED ))
			BEGIN 
				SELECT @currencyCode = deleted.[CurrencyCode] FROM DELETED;

				DELETE
				FROM Sales.CurrencyRate
				WHERE [ToCurrencyCode] = @currencyCode;

			IF ( NOT EXISTS ( SELECT 1 FROM Sales.CountryRegionCurrency WHERE [CurrencyCode] = @currencyCode))
				DELETE 
				FROM Sales.Currency
				WHERE [CurrencyCode] = @currencyCode
			END;
END;

/*
c) Вставьте новую строку в представление, указав новые данные для Currency и CurrencyRate (укажите FromCurrencyCode = ‘USD’). 
Триггер должен добавить новые строки в таблицы Sales.Currency и Sales.CurrencyRate. 
Обновите вставленные строки через представление. Удалите строки.
*/
INSERT INTO Sales.vCurrencyRate(
	[CurrencyRateDate],
	[FromCurrencyCode],
	[CurrencyCode],
	[Name],
	[AverageRate],
	[EndOfDayRate]
)
VALUES(
	GETDATE(), 
	'EUR',
	'USD', 
	'EURO1-1-US', 
	1.30, 
	1.20
);
GO


SELECT * FROM Sales.Currency 
	WHERE [CurrencyCode] = 'USD';     
SELECT * FROM Sales.CurrencyRate 
	WHERE [ToCurrencyCode] = 'USD';  


UPDATE Sales.vCurrencyRate
SET 
	[Name] ='EURO-2-US',
	[AverageRate] = 2.33,
	[EndOfDayRate] = 2.22
WHERE [CurrencyCode] = 'USD' AND [CurrencyRateID] = 12436;
GO

SELECT * FROM Sales.Currency 
	WHERE [CurrencyCode] = 'USD';       
SELECT * FROM Sales.CurrencyRate 
	WHERE [ToCurrencyCode] = 'USD'; 

DELETE 
FROM Sales.vCurrencyRate
	WHERE [CurrencyCode] = 'USD';
GO

SELECT * FROM Sales.Currency
	WHERE [CurrencyCode] = 'USD';
SELECT * FROM Sales.CurrencyRate 
	WHERE [ToCurrencyCode] = 'USD';  
SELECT * FROM Sales.CountryRegionCurrency
	WHERE [CurrencyCode] = 'USD';