CREATE PROCEDURE [dbo].[usp_CustomerLoad]

AS
BEGIN

SET NOCOUNT ON;  

DECLARE @trancount INT = @@TRANCOUNT;

	IF @trancount = 0
		BEGIN TRANSACTION; 
	ELSE 
		SAVE TRANSACTION trnCustomerImport;

	BEGIN TRY

	CREATE TABLE #staging_Customer
					(  
					CustomerID INT NOT NULL  
					PRIMARY KEY CLUSTERED (CustomerID)  
					);
					  
		CREATE TABLE #staging_Customer_intersect
					(  
					CustomerID int NOT NULL  
					PRIMARY KEY CLUSTERED (CustomerID)  
					);  

------
	-- preprocess out any key duplicates  
		UPDATE	dbo.Staging_Customer WITH(TABLOCKX)
		SET		LoadStatus = -4  
		WHERE	ID IN
				(  
				SELECT	ID   
				FROM	(  
						SELECT	ID  
								,ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY ID DESC) AS ranking  
						FROM	dbo.Staging_Customer
						) AS u  
				WHERE	u.ranking > 1  
				)  
------

---begin Upsert

INSERT INTO	#staging_Customer_intersect (CustomerID)  
		SELECT	CustomerID  
		FROM	dbo.Staging_Customer WITH(NOLOCK) 
		WHERE	LoadStatus = 0  --new
		INTERSECT
		SELECT	CustomerID  
		FROM	dbo.Customer WITH(NOLOCK);  

		UPDATE	dbo.Customer WITH(TABLOCKX)
		SET		Customer.FirstName = CONVERT(nvarchar(50), etl.FirstName)
				,Customer.LastName = CONVERT(nvarchar(50), etl.LastName)
				,Customer.PhoneNumber = CONVERT(INT, etl.PhoneNumber)
				,Customer.RegistrationDate = CONVERT(smalldatetime, etl.RegistrationDate)  
		OUTPUT	inserted.CustomerID  
		INTO	#staging_Customer
		FROM	dbo.Staging_Customer AS etl WITH(NOLOCK)  
				INNER JOIN #staging_Customer_intersect AS u   
					on u.CustomerID= etl.CustomerID
		WHERE	etl.LoadStatus = 0  
		AND		etl.CustomerID= Customer.CustomerID;


---

UPDATE	dbo.Staging_Customer WITH(TABLOCKX)   
		SET		LoadStatus = 2 -- update
		FROM	#staging_Customer updates  
		WHERE   updates.CustomerID = Staging_Customer.CustomerID 
		AND		LoadStatus = 0; --new

		TRUNCATE TABLE #staging_Customer; 

INSERT INTO dbo.Customer with(TABLOCKX)
					(CustomerID,
					FirstName,
					LastName,
					PhoneNumber,
					RegistrationDate  
					)  
		OUTPUT	inserted.CustomerID
		into	#staging_Customer  
		SELECT	CONVERT(INt, etl.CustomerID)  
				,CONVERT(nvarchar(50), etl.FirstName)
				,CONVERT(nvarchar(50), etl.LastName)
				,CONVERT(INT, etl.PhoneNumber)  
				,CONVERT(smalldatetime, etl.RegistrationDate)  
				 
		FROM	dbo.Staging_Customer AS etl with(NOLOCK)  
			
		WHERE	etl.LoadStatus = 0;   --new

		UPDATE	dbo.Staging_Customer with (TABLOCKX)   
		SET		LoadStatus = 1   --insert
		FROM	#staging_Customer inserts  
		WHERE  inserts.CustomerID = Staging_Customer.CustomerID 
		AND		LoadStatus = 0;  --new 


		DROP TABLE #staging_Customer;
		DROP TABLE #staging_Customer_intersect;
		

	IF @trancount = 0
			COMMIT TRAN; 

	END TRY  
	BEGIN CATCH  

		IF @trancount = 0 ROLLBACK;
		IF @trancount > 0 ROLLBACK TRANSACTION trnCustomerImport;

		RETURN -1;

	END CATCH
  
	RETURN 1;

END

