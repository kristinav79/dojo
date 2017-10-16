CREATE TABLE [dbo].[Staging_Orders]
(
	[Id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [OrderID] INT NOT NULL, 
    [CustomerID] INT NOT NULL, 
    [OrderDate] DATE NOT NULL, 
    [OrderStatus] NVARCHAR(50) NULL, 
    --[OrderTotal] REAL NULL,
	[ShippedDate] DATE NULL, 
    [LoadStatus] INT NOT NULL DEFAULT 0, 
    --[LoadDate] DATETIME NOT NULL DEFAULT GETDATE()
)
