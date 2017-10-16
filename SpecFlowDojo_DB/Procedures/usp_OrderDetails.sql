CREATE PROCEDURE [dbo].[usp_OrderDetails]

AS

BEGIN

SET NOCOUNT ON;  

DECLARE @trancount INT = @@TRANCOUNT;

	IF @trancount = 0
		BEGIN TRANSACTION; 
	ELSE 
		SAVE TRANSACTION trnOrderDetails;

	BEGIN TRY

	TRUNCATE TABLE dbo.OrderDetails;

	INSERT INTO dbo.OrderDetails (
		OrderID,
		CustomerID,
		OrderValue,
		OrderStatus,
		ShippedDate
									)

		SELECT a.OrderID
		,a.CustomerID
		,SUM(Quantity * UnitPrice) AS OrderValue
		,OrderStatus
		,ShippedDate
		FROM dbo.Orders a
		LEFT JOIN dbo.OrderItems c ON a.OrderID = c.OrderID
		group by a.OrderID, a.CustomerID,OrderStatus,ShippedDate

	IF @trancount = 0
			COMMIT TRAN; 

	END TRY  
	BEGIN CATCH  

		IF @trancount = 0 ROLLBACK;
		IF @trancount > 0 ROLLBACK TRANSACTION trnOrderDetails;

		RETURN -1;

	END CATCH
  
	RETURN 1;

END