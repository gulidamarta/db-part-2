USE AdventureWorks2012;
GO

/*
a) �������� � ������� dbo.PersonPhone ���� City ���� nvarchar(30);
*/
ALTER TABLE dbo.PersonPhone
	ADD City NVARCHAR(30);
GO

/*
b) �������� ��������� ���������� � ����� �� ���������� ��� dbo.PersonPhone � ��������� �� ������� �� dbo.PersonPhone. 
���� City ��������� ���������� �� ������� Person.Address ���� City, � ���� PostalCode 
���������� �� Person.Address ���� PostalCode. ���� ���� PostalCode �������� ����� � ��������� ���� ��������� �� ���������;
*/
DECLARE @PersonPhoneTableVar TABLE (
	BusinessEntityId INT NOT NULL,
	PhoneNumber NVARCHAR(25) NOT NULL,
	PhoneNumberTypeId BIGINT,
	ModifiedDate DATETIME NOT NULL,
	PostalCode NVARCHAR(15),
	City NVARCHAR(30)
);

-- ���������� ��������� ��������� ���������� ������� �� dbo.PersonPhone
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
c) �������� ������ � ����� PostalCode � City � dbo.PersonPhone ������� �� ��������� ����������. 
����� �������� ������ � ���� PhoneNumber. �������� ��� �1 (11)� ��� ��� ���������, ��� ������� ���� ��� �� ������;
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
d) ������� ������ �� dbo.PersonPhone ��� ����������� ��������, �� ���� ��� PersonType � Person.Person ����� �EM�;
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
e) ������� ���e City �� �������, ������� ��� ��������� ����������� � �������� �� ���������.
*/
ALTER TABLE dbo.PersonPhone
DROP COLUMN City;
GO

-- ����� ��� ����������� � ����������.
SELECT *
FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PersonPhone';
GO

-- ����� �������� �� ��������� � ����������.
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
f) ������� ������� dbo.PersonPhone.
*/
DROP TABLE dbo.PersonPhone;
GO




