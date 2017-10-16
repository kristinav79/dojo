CREATE TABLE [dbo].[Staging_Customer]
(
	[Id] INT NOT NULL PRIMARY KEY IDENTITY , 
    --[LoadDate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [CustomerID] INT NOT NULL, 
    [FirstName] NVARCHAR(50) NULL,
	[LastName] NVARCHAR(50) NULL,
	[PhoneNumber] INT NULL,
    [RegistrationDate] DATE NOT NULL, 
    [LoadStatus] INT NOT NULL DEFAULT 0, 
    
)
