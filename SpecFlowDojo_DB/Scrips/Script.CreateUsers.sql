/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
/****************************************************************************************
* Database: Wesleyan_CDS
* Author  : Tadas Gedminas
* Date    : 03/08/2017
* Purpose : Create Users and add to Roles for all databases
*
* Version History
* ---------------
* 1.0 03/08/2017 Tadas Gedminas
* Script created
* 1.1 14/09/2017 Rasa Mozuraite
* Script updated
****************************************************************************************/
DECLARE @USERS_TMP TABLE (
	RN INT IDENTITY NOT NULL
	,[Name] VARCHAR(1000) NOT NULL
	,[DBname] VARCHAR(1000) NOT NULL
	)

--Add logins and databases here
INSERT INTO @USERS_TMP (
	NAME
	,DBname
	)
VALUES 
('DESKTOP-JPDDF3A\Svecias', 'SpecFlowDojo')


--Declare variables
DECLARE @m INT
	,@c INT = 1
	,@userName SYSNAME
	,@SqlStatement NVARCHAR(4000)
	,@Role NVARCHAR(100)
	,@DatabaseName NVARCHAR(128)

--Get max number
SELECT @m = MAX(RN)
FROM @USERS_TMP;

-- Loop through users
WHILE @m >= @c
BEGIN
	SELECT @userName = [Name]
	FROM @USERS_TMP
	WHERE RN = @c

	SELECT @DatabaseName = [DBname]
	FROM @USERS_TMP
	WHERE RN = @c

	--Check if user not exists and not exists under different name
	IF NOT EXISTS (
			SELECT [name]
			FROM sys.server_principals
			WHERE lower([name]) = lower(@userName)
			)
		AND NOT EXISTS (
			SELECT [name]
			FROM sys.server_principals
			WHERE [sid] = SUSER_SID(lower(@userName))
			)
	BEGIN
		-- Create if not exist
		PRINT ('CREATING LOGIN FOR: ' + @userName)

		SELECT @SqlStatement = 'CREATE LOGIN ' + QUOTENAME(@userName) + '
		FROM WINDOWS WITH DEFAULT_DATABASE=     [master], DEFAULT_LANGUAGE=[British]';

		EXEC sp_executesql @stmt = @SqlStatement;
	END

	--Check if Database  exists 
	IF (
			EXISTS (
				SELECT [name]
				FROM sys.databases
				WHERE (
						'[' + NAME + ']' = @DatabaseName
						OR NAME = @DatabaseName
						)
				)
			)
	BEGIN
		PRINT ('Adding users for database ' + @DatabaseName);

		EXECUTE [dbo].[up_Create_User] @DatabaseName = @DatabaseName
			,@UserName = @userName;
--Add Role Membership--
		SET @Role = 'db_owner'
		EXECUTE dbo.up_Add_Role_Member @DatabaseName = @DatabaseName
			,@RoleName = @Role
			,@UserName = @userName;
	END
	ELSE
	BEGIN
		PRINT ('Database ' + @DatabaseName + ' does not exist');
	END

	-- Increase counter
	SELECT @c += 1;
END
GO

