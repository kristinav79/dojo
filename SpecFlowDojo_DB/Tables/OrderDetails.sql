CREATE TABLE [dbo].[OrderDetails]
(
	[OrderID] INT NOT NULL PRIMARY KEY, 
    [CustomerID] INT NOT NULL, 
    [OrderValue] DECIMAL(18, 2) NULL, 
    [OrderStatus] NVARCHAR(50) NULL, 
    [ShippedDate] DATE NULL
)
