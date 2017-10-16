CREATE TABLE [dbo].[CustomerProfile]
(
    [CustomerID] INT NOT NULL, 
    [TotalOrderCount] INT NULL, 
    --[TotalOrdersValue] REAL NULL,
	[FirstOrderDate] DATE NULL, 
    [RegistrationDate] DATE NOT NULL, 
    PRIMARY KEY ([CustomerID])
)
