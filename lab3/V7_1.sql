USE AdventureWorks2012;
GO

/*
a) добавьте в таблицу dbo.PersonPhone поле City типа nvarchar(30);
*/
ALTER TABLE dbo.PersonPhone
	ADD City NVARCHAR(30);
GO

/*
b) объявите табличную переменную с такой же структурой как dbo.PersonPhone и заполните ее данными из dbo.PersonPhone. 
Поле City заполните значениями из таблицы Person.Address поля City, а поле PostalCode 
значениями из Person.Address поля PostalCode. Если поле PostalCode содержит буквы — заполните поле значением по умолчанию;
*/
DECLARE @PersonPhoneTableVar TABLE (
	BusinessEntityId INT NOT NULL,
	PhoneNumber NVARCHAR(25) NOT NULL,
	PhoneNumberTypeId BIGINT,
	ModifiedDate DATETIME NOT NULL,
	PostalCode NVARCHAR(15),
	City NVARCHAR(30)
);

-- Заполнение созданной табличной переменной данными из dbo.PersonPhone
INSERT INTO @PersonPhoneTableVar(
	BusinessEntityId,
	PhoneNumber,
	PhoneNumberTypeId,
	ModifiedDate,
	PostalCode,
	City
)
SELECT 
	PersonPhone.BusinessEntityID,
	PersonPhone.PhoneNumber,
	PersonPhone.PhoneNumberTypeID,
	PersonPhone.ModifiedDate,
	CASE
		WHEN Address.PostalCode LIKE '[A-Za-z]%' THEN '0'
		ELSE Address.PostalCode
	END,
	Address.City
FROM dbo.PersonPhone AS PersonPhone
INNER JOIN Person.BusinessEntityAddress 
ON PersonPhone.BusinessEntityID = Person.BusinessEntityAddress.BusinessEntityID
INNER JOIN Person.Address AS Address
ON Address.AddressID = Person.BusinessEntityAddress.AddressID;

/*
c) обновите данные в полях PostalCode и City в dbo.PersonPhone данными из табличной переменной. 
Также обновите данные в поле PhoneNumber. Добавьте код ‘1 (11)’ для тех телефонов, для которых этот код не указан;
*/
UPDATE dbo.PersonPhone
	SET 
		dbo.PersonPhone.PostalCode = PersonPhoneTableVar.PostalCode,
		dbo.PersonPhone.City = PersonPhoneTableVar.City,
		dbo.PersonPhone.PhoneNumber = 
		CASE 
			WHEN PATINDEX('%1 (11)%', dbo.PersonPhone.PhoneNumber) = 0 THEN
			'1 (11)' + dbo.PersonPhone.PhoneNumber 
			ELSE
			dbo.PersonPhone.PhoneNumber
		END
FROM dbo.PersonPhone 
INNER JOIN @PersonPhoneTableVar AS PersonPhoneTableVar
ON dbo.PersonPhone.BusinessEntityID = PersonPhoneTableVar.BusinessEntityID;
GO

SELECT * FROM dbo.PersonPhone;

/*
d) удалите данные из dbo.PersonPhone для сотрудников компании, то есть где PersonType в Person.Person равен ‘EM’;
*/
SELECT * from Person.Person;
SELECT * from dbo.PersonPhone;

DELETE FROM dbo.PersonPhone
WHERE EXISTS(
	SELECT BusinessEntityID, PersonType 
	FROM Person.Person
	WHERE Person.BusinessEntityID = dbo.PersonPhone.BusinessEntityID
	AND Person.PersonType = 'EM'
);
GO

SELECT * FROM dbo.PersonPhone;
GO

/*
e) удалите полe City из таблицы, удалите все созданные ограничения и значения по умолчанию.
*/
ALTER TABLE dbo.PersonPhone
DROP COLUMN City;
GO

-- Поиск имён ограничений в метаданных.
SELECT *
FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PersonPhone';
GO

-- Поиск значений по умолчанию в метаданных.
SELECT *
FROM AdventureWorks2012.INFORMATION_SCHEMA.CHECK_CONSTRAINTS;
GO

ALTER TABLE dbo.PersonPhone
DROP CONSTRAINT CHK_PostalCode;
GO

ALTER TABLE dbo.PersonPhone
DROP CONSTRAINT DF_PersonPhone_PostalCode;
GO

/*
f) удалите таблицу dbo.PersonPhone.
*/
DROP TABLE dbo.PersonPhone;
GO




