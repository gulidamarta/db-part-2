USE AdventureWorks2012;
GO

/*
a) Создайте таблицу Sales.CurrencyHst, которая будет хранить информацию об изменениях в таблице Sales.Currency.

Обязательные поля, которые должны присутствовать в таблице: 
	ID — первичный ключ IDENTITY(1,1); 
	Action — совершенное действие (insert, update или delete); 
	ModifiedDate — дата и время, когда была совершена операция; 
	SourceID — первичный ключ исходной таблицы; 
	UserName — имя пользователя, совершившего операцию. 
Создайте другие поля, если считаете их нужными.
*/

CREATE TABLE Sales.CurrencyHst
(
    [ID] INT IDENTITY (1,1) PRIMARY KEY,
    [Action] CHAR(6) NOT NULL CHECK ([Action] in ('insert', 'update', 'delete')),
    [ModifiedDate] DATETIME NOT NULL,
    [SourceID] NCHAR(3) NOT NULL,
    [UserName] VARCHAR(50) NOT NULL
);
GO

/*
b) Создайте три AFTER триггера для трех операций INSERT, UPDATE, DELETE для таблицы Sales.Currency. 
Каждый триггер должен заполнять таблицу Sales.CurrencyHst с указанием типа операции в поле Action.
*/
-- Триггер для операции INSERT
CREATE TRIGGER TR_SalesCurrency_AfterInsert
	ON Sales.Currency
AFTER INSERT AS 
BEGIN
	INSERT INTO Sales.CurrencyHst(
		[Action], 
		[ModifiedDate], 
		[SourceID], 
		[UserName]
	)
	SELECT 
		'insert', 
		CURRENT_TIMESTAMP, 
		CurrencyCode, 
		CURRENT_USER
	FROM inserted;
END
GO

-- Триггер для операции DELETE
CREATE TRIGGER TR_SalesCurrency_AfterDelete
	ON Sales.Currency
AFTER DELETE AS 
BEGIN
	INSERT INTO Sales.CurrencyHst(
		[Action], 
		[ModifiedDate], 
		[SourceID], 
		[UserName]
	)
	SELECT 
		'delete', 
		CURRENT_TIMESTAMP, 
		CurrencyCode, 
		CURRENT_USER
	FROM deleted;
END
GO

-- Триггер для операции UPDATE
CREATE TRIGGER TR_SalesCurrency_AfterUpdate
	ON Sales.Currency
AFTER UPDATE AS 
BEGIN
	INSERT INTO Sales.CurrencyHst(
		[Action], 
		[ModifiedDate], 
		[SourceID], 
		[UserName]
	)
	SELECT 
		'update', 
		CURRENT_TIMESTAMP, 
		CurrencyCode, 
		CURRENT_USER
	FROM deleted;
END
GO

/*
c) Создайте представление VIEW, отображающее все поля таблицы Sales.Currency. 
Сделайте невозможным просмотр исходного кода представления.
*/
CREATE VIEW Sales.vCurrency 
	WITH ENCRYPTION AS
		SELECT * FROM Sales.Currency;
GO

-- Проверка того, что получить представление невозможно
SELECT  
	definition    
FROM sys.sql_modules 
WHERE 
	object_id = object_id('Sales.vCurrency');
GO

/*
d) Вставьте новую строку в Sales.Currency через представление. 
Обновите вставленную строку. 
Удалите вставленную строку. 
Убедитесь, что все три операции отображены в Sales.CurrencyHst.
*/
-- Вставка новой строки
INSERT INTO Sales.vCurrency(
	[CurrencyCode],
	[Name],
	[ModifiedDate]
)
VALUES (
	N'MSD',
	'MY Dollar',
	CURRENT_TIMESTAMP
);
GO

-- Обновление вставленной строки 
UPDATE Sales.vCurrency
	SET [Name] = 'Moderated Dollar'
		WHERE [CurrencyCode] = N'MSD';
GO

-- Удаление вставленной строки
DELETE FROM Sales.vCurrency
	WHERE [CurrencyCode] = N'MSD';
GO
 
-- Проверка корректности отображения выполненных операций в Sales.CurrencyHst
SELECT * FROM Sales.CurrencyHst;
GO
