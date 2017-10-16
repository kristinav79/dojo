CREATE TABLE [dbo].[Customer]
(
    [CustomerID] INT NOT NULL, 
    [FirstName] NVARCHAR(50) NULL,
	[LastName] NVARCHAR(50) NULL,
	[PhoneNumber] INT NULL, 
    [RegistrationDate] DATE NOT NULL, 
    PRIMARY KEY ([CustomerID])
)
