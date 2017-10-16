CREATE TABLE [dbo].[Staging_OrderItems]
(
	[Id] INT NOT NULL PRIMARY KEY IDENTITY, 
    --[LoadDate] DATETIME NOT NULL DEFAULT GETDATE(),
	[OrderLineID] INT NOT NULL,
	[ItemID] INT NOT NULL, 
    [ItemName] NVARCHAR(50) NULL, 
    [OrderID] INT NOT NULL, 
    [Quantity] INT NOT NULL, 
    [UnitPrice] DECIMAL(18, 2) NOT NULL, 
    [LoadStatus] INT NOT NULL DEFAULT 0
)
