CREATE TABLE [dbo].[Orders]
(
    [OrderID] INT NOT NULL, 
    [CustomerID] INT NOT NULL, 
    [OrderDate] DATE NOT NULL, 
    [OrderStatus] NVARCHAR(50) NULL, 
    --[OrderTotal] REAL NULL,
	[ShippedDate] DATE NULL 
    PRIMARY KEY ([OrderID]), 
    --CONSTRAINT [FK_Orders_Customer] FOREIGN KEY ([CustomerID]) REFERENCES [Customer]([CustomerID])
)
