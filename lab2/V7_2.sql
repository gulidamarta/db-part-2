USE AdventureWorks2012;
GO

/*
a) create a dbo.PersonPhone table with the same structure as Person.PersonPhone, 
excluding indexes, constraints and triggers;
*/
CREATE TABLE dbo.PersonPhone (
	[BusinessEntityID] INT NOT NULL,
	[PhoneNumber] NVARCHAR(25) NOT NULL,
	[PhoneNumberTypeID] INT NOT NULL,
	[ModifiedDate] DATETIME NOT NULL,
);
GO

/*
b) Using the ALTER TABLE statement, create a composite primary key for the dbo.PersonPhone 
table from the BusinessEntityID and PhoneNumber fields;
*/
ALTER TABLE dbo.PersonPhone
	ADD CONSTRAINT PK_PersonPhones 
	PRIMARY KEY ([BusinessEntityID], [PhoneNumber]);
GO

/*
c) using the ALTER TABLE statement, create a new PostalCode nvarchar (15) field for the dbo.PersonPhone 
table and a constraint for this field to prevent this field from being filled with letters;
*/
ALTER TABLE dbo.PersonPhone
	ADD [PostalCode] NVARCHAR(15),
	CONSTRAINT CHK_PostalCode CHECK (
		[PostalCode] NOT LIKE '%[a-zA-Z]%'
	);
GO

/*
d) using the ALTER TABLE statement, create a DEFAULT constraint for the PostalCode field for the dbo.PersonPhone table, 
set the default to ‘0’;
*/
ALTER TABLE dbo.PersonPhone
	ADD CONSTRAINT DF_PersonPhone_PostalCode
		DEFAULT '0' FOR [PostalCode];
GO


/*
e) fill the new table with data from Person.PersonPhone, only 
with contacts with the ‘Cell’ type from the PhoneNumberType table;
*/
INSERT INTO dbo.PersonPhone(
	[BusinessEntityID],
	[PhoneNumber],
	[PhoneNumberTypeID],
	[ModifiedDate]
)
SELECT PersonPhone.[BusinessEntityID], 
	PersonPhone.[PhoneNumber],
	PersonPhone.[PhoneNumberTypeID],
	PersonPhone.[ModifiedDate]
FROM Person.PersonPhone as PersonPhone
INNER JOIN Person.PhoneNumberType as PhoneNumberType
	ON PhoneNumberType.[PhoneNumberTypeID] = PersonPhone.[PhoneNumberTypeID]
		WHERE PhoneNumberType.[Name] = 'Cell';
GO

/*
f) change the field type PhoneNumberTypeID to bigint and and make it nullable.
*/
ALTER TABLE dbo.PersonPhone
	ALTER COLUMN [PhoneNumberTypeID] BIGINT NULL;
GO