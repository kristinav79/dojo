CREATE TABLE [dbo].[OrderItems]
(
	[OrderLineID] INT NOT NULL PRIMARY KEY,
	[ItemID] INT NOT NULL, 
    [ItemName] NVARCHAR(50) NULL, 
    [OrderID] INT NOT NULL, 
    [Quantity] INT NOT NULL, 
    [UnitPrice] DECIMAL(18, 2) NOT NULL
)
