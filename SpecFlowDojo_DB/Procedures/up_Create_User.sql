/****************************************************************************************
* Database: Wesleyan_CDS
* Author  : Tadas Gedminas
* Date    : 16/08/2017
* Purpose : Add user to database for specific database
* Input   : 
* Output  : 
*
* Version History
* ---------------
* 1.0 16/08/2017 Tadas Gedminas
* Procedure created.
****************************************************************************************/
CREATE PROCEDURE [dbo].[up_Create_User]
	@DatabaseName NVARCHAR(128) = NULL,
	@UserName NVARCHAR(128) = NULL
AS
BEGIN
	DECLARE @SqlStatement NVARCHAR(4000);

	-- If Database is null then set to current database
	IF @DatabaseName IS NULL 
	BEGIN
		SET @DatabaseName = DB_NAME();
	END

	-- Check if username IS NOT NULL
	IF(@UserName IS NOT NULL)
	BEGIN
		-- Format SQL
		SELECT @SqlStatement = ('
			USE [' + @DatabaseName + '] 
			IF NOT EXISTS(SELECT principal_id FROM sys.database_principals WHERE lower(name) = lower('''+@userName+'''))
			BEGIN
				PRINT (''CREATING USER FOR: ' + @userName+''');
				CREATE USER ' + QUOTENAME(@userName) + ' FOR LOGIN ' + QUOTENAME(@userName)+'
			END');

		-- Run
		EXEC sp_executesql @stmt = @SqlStatement;
	END
	ELSE
	BEGIN
		-- Notify User
		PRINT('@UserName cannot be NULL');
	END
END

GO
