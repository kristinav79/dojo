CREATE PROCEDURE [dbo].[usp_CustomerProfile]

AS
BEGIN

SET NOCOUNT ON;  

DECLARE @trancount INT = @@TRANCOUNT;

	IF @trancount = 0
		BEGIN TRANSACTION; 
	ELSE 
		SAVE TRANSACTION trnCustomerProfile;

	BEGIN TRY

	TRUNCATE TABLE dbo.CustomerProfile;

	INSERT INTO dbo.CustomerProfile (
		CustomerID,
		TotalOrderCount,
		--TotalOrdersValue,
		FirstOrderDate,
		RegistrationDate
									)

	SELECT	c.CustomerID, 
			COUNT(o.OrderID),
			--SUM (o.OrderTotal),
			MIN(o.OrderDate),
			MIN(c.RegistrationDate)  
		FROM dbo.Customer c
			LEFT JOIN dbo.Orders o ON c.CustomerID=o.CustomerID
			--WHERE c.CustomerID=o.CustomerID
		GROUP BY c.CustomerID

	IF @trancount = 0
			COMMIT TRAN; 

	END TRY  
	BEGIN CATCH  

		IF @trancount = 0 ROLLBACK;
		IF @trancount > 0 ROLLBACK TRANSACTION trnCustomerProfile;

		RETURN -1;

	END CATCH
  
	RETURN 1;

END

