CREATE PROCEDURE [dbo].[usp_OrderItemsLoad]

AS

BEGIN

SET NOCOUNT ON;  

DECLARE @trancount INT = @@TRANCOUNT;

	IF @trancount = 0
		BEGIN TRANSACTION; 
	ELSE 
		SAVE TRANSACTION trnOrderItemsImport;

	BEGIN TRY

	CREATE TABLE #staging_OrderItems
					(  
					OrderLineID INT NOT NULL  
					PRIMARY KEY CLUSTERED (OrderLineID)  
					);
					  
		CREATE TABLE #staging_OrderItems_intersect
					(  
					OrderLineID int NOT NULL  
					PRIMARY KEY CLUSTERED (OrderLineID)  
					);  

------
	-- preprocess out any key duplicates  
		UPDATE	dbo.Staging_OrderItems WITH(TABLOCKX)
		SET		LoadStatus = -4  
		WHERE	ID IN
				(  
				SELECT	ID   
				FROM	(  
						SELECT	ID  
								,ROW_NUMBER() OVER (PARTITION BY OrderLineID ORDER BY ID DESC) AS ranking  
						FROM	dbo.Staging_OrderItems
						) AS u  
				WHERE	u.ranking > 1  
				)  
------

---begin Upsert

INSERT INTO	#staging_OrderItems_intersect (OrderLineID)  
		SELECT	OrderLineID  
		FROM	dbo.Staging_OrderItems WITH(NOLOCK) 
		WHERE	LoadStatus = 0  --new
		INTERSECT
		SELECT	OrderLineID  
		FROM	dbo.OrderItems WITH(NOLOCK);  

		UPDATE	dbo.OrderItems WITH(TABLOCKX)
		SET		OrderItems.ItemID = CONVERT(INT, etl.ItemID)
				,OrderItems.ItemName = CONVERT(nvarchar(50), etl.ItemName)
				,OrderItems.OrderID = CONVERT(INT, etl.OrderID)
				,OrderItems.Quantity = CONVERT(INT, etl.Quantity)
				,OrderItems.UnitPrice = CONVERT(real, etl.UnitPrice)  
		OUTPUT	inserted.OrderLineID  
		INTO	#staging_OrderItems
		FROM	dbo.Staging_OrderItems AS etl WITH(NOLOCK)  
				INNER JOIN #staging_OrderItems_intersect AS u   
					on u.OrderLineID= etl.OrderLineID
		WHERE	etl.LoadStatus = 0  
		AND		etl.OrderLineID= OrderItems.OrderLineID;


---

UPDATE	dbo.Staging_OrderItems WITH(TABLOCKX)   
		SET		LoadStatus = 2 -- update
		FROM	#staging_OrderItems updates  
		WHERE   updates.OrderLineID = Staging_OrderItems.OrderLineID 
		AND		LoadStatus = 0; --new

		TRUNCATE TABLE #staging_OrderItems; 

INSERT INTO dbo.OrderItems with(TABLOCKX)
					(OrderLineID,
					ItemID,
					ItemName,
					OrderID,
					Quantity,
					UnitPrice					
					)  
		OUTPUT	inserted.OrderLineID
		into	#staging_OrderItems  
		SELECT	CONVERT(INt, etl.OrderLineID)
				,CONVERT(INt, etl.ItemID)
				,CONVERT(nvarchar(50), etl.ItemName)  
				,CONVERT(int, etl.OrderID)
				,CONVERT(int, etl.Quantity) 
				,CONVERT(real, etl.UnitPrice)  
				 
		FROM	dbo.Staging_OrderItems AS etl with(NOLOCK)  
			
		WHERE	etl.LoadStatus = 0;   --new

		UPDATE	dbo.Staging_OrderItems with (TABLOCKX)   
		SET		LoadStatus = 1   --insert
		FROM	#staging_OrderItems inserts  
		WHERE  inserts.OrderLineID = Staging_OrderItems.OrderLineID 
		AND		LoadStatus = 0;  --new 


		DROP TABLE #staging_OrderItems;
		DROP TABLE #staging_OrderItems_intersect;
		

	IF @trancount = 0
			COMMIT TRAN; 

	END TRY  
	BEGIN CATCH  

		IF @trancount = 0 ROLLBACK;
		IF @trancount > 0 ROLLBACK TRANSACTION trnOrderItemsImport;

		RETURN -1;

	END CATCH
  
	RETURN 1;

END