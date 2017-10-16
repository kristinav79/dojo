/****************************************************************************************
* Database: Wesleyan_CDS
* Author  : Tadas Gedminas
* Date    : 16/08/2017
* Purpose : Add user to database role for specific database
* Input   : 
* Output  : 
*
* Version History
* ---------------
* 1.0 16/08/2017 Tadas Gedminas
* Procedure created.
****************************************************************************************/
CREATE PROCEDURE [dbo].[up_Add_Role_Member]
	@DatabaseName NVARCHAR(128) = NULL,
	@RoleName NVARCHAR(128) = NULL,
	@UserName NVARCHAR(128) = NULL
AS
BEGIN
	DECLARE @SqlStatement NVARCHAR(4000);

	-- If Database is null then set to current database
	IF @DatabaseName IS NULL 
	BEGIN
		SET @DatabaseName = DB_NAME();
	END

	-- Check if other parameters IS NOT NULL
	IF(@RoleName IS NOT NULL AND @UserName IS NOT NULL)
	BEGIN
		-- Format SQL
		SELECT @SqlStatement = ('
			USE [' + @DatabaseName + '] 
			IF ISNULL(IS_ROLEMEMBER('''+@RoleName+''', '''+@UserName+'''),0) = 0 AND DATABASE_PRINCIPAL_ID('''+@RoleName+''') IS NOT NULL 
			BEGIN
				PRINT (''Add ' + @RoleName + ' role for user ' + @UserName + ''');
				EXEC sp_addrolemember ''' + @RoleName + ''', ''' + @UserName+'''
			END
			');

			-- Run
			EXECUTE sp_executesql @stmt = @SqlStatement;
	END
	ELSE
	BEGIN
		-- Notify user
		PRINT('Role or User cannot be NULL');
	END
END

GO
