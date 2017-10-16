CREATE PROCEDURE [dbo].[usp_OrdersLoad]
	
AS

BEGIN

SET NOCOUNT ON;  

DECLARE @trancount INT = @@TRANCOUNT;

	IF @trancount = 0
		BEGIN TRANSACTION; 
	ELSE 
		SAVE TRANSACTION trnOrderImport;

	BEGIN TRY

	CREATE TABLE #staging_Orders
					(  
					OrderID INT NOT NULL  
					PRIMARY KEY CLUSTERED (OrderID)  
					);
					  
		CREATE TABLE #staging_Orders_intersect
					(  
					OrderID int NOT NULL  
					PRIMARY KEY CLUSTERED (OrderID)  
					);  

------
	-- preprocess out any key duplicates  
		UPDATE	dbo.Staging_Orders WITH(TABLOCKX)
		SET		LoadStatus = -4  
		WHERE	ID IN
				(  
				SELECT	ID   
				FROM	(  
						SELECT	ID  
								,ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY ID DESC) AS ranking  
						FROM	dbo.Staging_Orders
						) AS u  
				WHERE	u.ranking > 1  
				)  
------

---begin Upsert

INSERT INTO	#staging_Orders_intersect (OrderID)  
		SELECT	OrderID  
		FROM	dbo.Staging_Orders WITH(NOLOCK) 
		WHERE	LoadStatus = 0  --new
		INTERSECT
		SELECT	OrderID  
		FROM	dbo.Orders WITH(NOLOCK);  

		UPDATE	dbo.Orders WITH(TABLOCKX)
		SET		Orders.CustomerID = CONVERT(INT, etl.CustomerID)
				,Orders.OrderDate = CONVERT(date, etl.OrderDate)
				,Orders.OrderStatus = CONVERT(nvarchar(50), etl.OrderStatus)
				,Orders.ShippedDate = CONVERT(date, etl.ShippedDate)  
		OUTPUT	inserted.OrderID  
		INTO	#staging_Orders
		FROM	dbo.Staging_Orders AS etl WITH(NOLOCK)  
				INNER JOIN #staging_Orders_intersect AS u   
					on u.OrderID= etl.OrderID
		WHERE	etl.LoadStatus = 0  
		AND		etl.OrderID= Orders.OrderID;


---

UPDATE	dbo.Staging_Orders WITH(TABLOCKX)   
		SET		LoadStatus = 2 -- update
		FROM	#staging_Orders updates  
		WHERE   updates.OrderID = Staging_Orders.OrderID 
		AND		LoadStatus = 0; --new

		TRUNCATE TABLE #staging_Orders; 

INSERT INTO dbo.Orders with(TABLOCKX)
					(OrderID,
					CustomerID,
					OrderDate,
					OrderStatus,
					ShippedDate					
					)  
		OUTPUT	inserted.OrderID
		into	#staging_Orders  
		SELECT	CONVERT(INt, etl.OrderID)
				,CONVERT(INt, etl.CustomerID)  
				,CONVERT(date, etl.OrderDate)
				,CONVERT(nvarchar(50), etl.OrderStatus) 
				,CONVERT(date, etl.ShippedDate)  
				 
		FROM	dbo.Staging_Orders AS etl with(NOLOCK)  
			
		WHERE	etl.LoadStatus = 0;   --new

		UPDATE	dbo.Staging_Orders with (TABLOCKX)   
		SET		LoadStatus = 1   --insert
		FROM	#staging_Orders inserts  
		WHERE  inserts.OrderID = Staging_Orders.OrderID 
		AND		LoadStatus = 0;  --new 


		DROP TABLE #staging_Orders;
		DROP TABLE #staging_Orders_intersect;
		

	IF @trancount = 0
			COMMIT TRAN; 

	END TRY  
	BEGIN CATCH  

		IF @trancount = 0 ROLLBACK;
		IF @trancount > 0 ROLLBACK TRANSACTION trnOrderImport;

		RETURN -1;

	END CATCH
  
	RETURN 1;

END



