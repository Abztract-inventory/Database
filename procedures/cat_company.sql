--cat_company.sql
--create
CREATE OR ALTER PROCEDURE [dbo].[createCatCompany]
    @companyName varchar(100),
    @idOut int = NULL OUTPUT
AS
    SET NOCOUNT ON;
    DECLARE @tranCount int;
    SET @tranCount = @@TRANCOUNT;
BEGIN
    BEGIN TRY
        IF @tranCount = 0
            BEGIN TRANSACTION
        ELSE
            SAVE TRANSACTION [createCatCompany];
            DECLARE @errors varchar(max);
            DECLARE @id TABLE(id int);

            IF EXISTS(SELECT id FROM cat_company WHERE name = @companyName)
                SET @errors = CONCAT(@errors, 'Empresa ya registrada: ', @companyName, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    INSERT INTO 
                        cat_company(dateCreated, dateModified, name)
                    OUTPUT inserted.id INTO @id
                    VALUES 
                        (GETDATE(), GETDATE(), @companyName)
                    SELECT TOP 1 @idOut = id FROM @id
                    SELECT 1 AS affects_rows, NULL AS error, @idOut AS id;
                END
            ELSE
                BEGIN
                    SELECT 0 AS affects_rows, @errors AS error, @idOut AS id;
                END
        lbexit:
            IF @tranCount = 0
                COMMIT;
    END TRY
    BEGIN CATCH
        DECLARE @error int, @message varchar(4000), @xstate int;
        SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();
        IF @xstate = -1
            ROLLBACK;
        IF @xstate = 1
            ROLLBACK;
        IF @xstate = 1 AND @tranCount > 0
            ROLLBACK TRANSACTION [createCatCompany];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[updateCatCompany]
    @companyId int,
    @companyName varchar(100),
    @idOut int = NULL OUTPUT
AS
    SET NOCOUNT ON;
    DECLARE @tranCount int;
    SET @tranCount = @@TRANCOUNT;
BEGIN
    BEGIN TRY
        IF @tranCount = 0
            BEGIN TRANSACTION
        ELSE
            SAVE TRANSACTION [updateCatCompany];
            DECLARE @errors varchar(max);
            DECLARE @currentName varchar(100);
            SELECT @currentName = name FROM cat_company WHERE id = @companyId

            IF NOT EXISTS(SELECT id FROM cat_company WHERE id = @companyId)
                SET @errors = CONCAT(@errors, 'Empresa no encontrada: ', @companyName, CHAR(13), CHAR(10));

            ELSE IF (@currentName = @companyName)
                SET @errors = CONCAT(@errors, 'El nombre no puede ser el mismo: ', @companyName, CHAR(13), CHAR(10));

            ELSE IF (@currentName <> @companyName) AND EXISTS(SELECT name FROM cat_company WHERE name = @companyName)
                SET @errors = CONCAT(@errors, 'Empresa ya registrada: ', @companyName, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    UPDATE 
                        cat_company
                    SET
                        name = @companyName,
                        dateModified = GETDATE()
                    WHERE 
                        id = @companyId
                    SELECT 1 AS affects_rows, NULL AS error, @idOut AS id;
                END
            ELSE
                BEGIN
                    SELECT 0 AS affects_rows, @errors AS error, @idOut AS id;
                END
        lbexit:
            IF @tranCount = 0
                COMMIT;
    END TRY
    BEGIN CATCH
        DECLARE @error int, @message varchar(4000), @xstate int;
        SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();
        IF @xstate = -1
            ROLLBACK;
        IF @xstate = 1
            ROLLBACK;
        IF @xstate = 1 AND @tranCount > 0
            ROLLBACK TRANSACTION [updateCatCompany];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[deleteCatCompany]
    @companyId int,
    @idOut int = NULL OUTPUT
AS
    SET NOCOUNT ON;
    DECLARE @tranCount int;
    SET @tranCount = @@TRANCOUNT;
BEGIN
    BEGIN TRY
        IF @tranCount = 0
            BEGIN TRANSACTION
        ELSE
            SAVE TRANSACTION [deleteCatCompany];
            DECLARE @errors varchar(max);

            IF NOT EXISTS(SELECT id FROM cat_company WHERE id = @companyId)
                SET @errors = CONCAT(@errors, 'Empresa no encontrada: ', @companyId, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    DELETE FROM
                        cat_company
                    WHERE  
                        id = @companyId
                    SELECT 1 AS affects_rows, NULL AS error, @idOut AS id;
                END
            ELSE
                BEGIN
                    SELECT 0 AS affects_rows, @errors AS error, @idOut AS id;
                END
        lbexit:
            IF @tranCount = 0
                COMMIT;
    END TRY
    BEGIN CATCH
        DECLARE @error int, @message varchar(4000), @xstate int;
        SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();
        IF @xstate = -1
            ROLLBACK;
        IF @xstate = 1
            ROLLBACK;
        IF @xstate = 1 AND @tranCount > 0
            ROLLBACK TRANSACTION [deleteCatCompany];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO