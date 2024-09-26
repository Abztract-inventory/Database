--cat_currency.sql
--create
CREATE OR ALTER PROCEDURE [dbo].[create_cat_currency]
    @currencyName varchar(100),
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
            SAVE TRANSACTION [create_cat_currency];
            DECLARE @errors varchar(max);
            DECLARE @id TABLE(id int);

            IF EXISTS(SELECT id FROM cat_currency WHERE name = @currencyName)
                SET @errors = CONCAT(@errors, 'Tipo de cambio ya registrado: ', @currencyName, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    INSERT INTO 
                        cat_currency(dateCreated, dateModified, name)
                    OUTPUT inserted.id INTO @id
                    VALUES 
                        (GETDATE(), GETDATE(), @currencyName)
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
            ROLLBACK TRANSACTION [create_cat_currency];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[update_cat_currency]
    @currencyId int,
    @currencyName varchar(100),
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
            SAVE TRANSACTION [update_cat_currency];
            DECLARE @errors varchar(max);
            DECLARE @currentName varchar(100);
            SELECT @currentName = name FROM cat_currency WHERE id = @currencyId

            IF NOT EXISTS(SELECT id FROM cat_currency WHERE id = @currencyId)
                SET @errors = CONCAT(@errors, 'Tipo de cambio no encontrado: ', @currencyName, CHAR(13), CHAR(10));

            ELSE IF (@currentName = @currencyName)
                SET @errors = CONCAT(@errors, 'El nombre no puede ser el mismo: ', @currencyName, CHAR(13), CHAR(10));

            ELSE IF (@currentName <> @currencyName) AND EXISTS(SELECT name FROM cat_currency WHERE name = @currencyName)
                SET @errors = CONCAT(@errors, 'Tipo de cambio ya registrado: ', @currencyName, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    UPDATE 
                        cat_currency
                    SET
                        name = @currencyName,
                        dateModified = GETDATE()
                    WHERE 
                        id = @currencyId
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
            ROLLBACK TRANSACTION [update_cat_currency];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_cat_currency]
    @currencyId int,
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
            SAVE TRANSACTION [delete_cat_currency];
            DECLARE @errors varchar(max);

            IF NOT EXISTS(SELECT id FROM cat_currency WHERE id = @currencyId)
                SET @errors = CONCAT(@errors, 'Tipo de cambio no encontrado: ', @currencyId, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    DELETE FROM
                        cat_currency
                    WHERE  
                        id = @currencyId
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
            ROLLBACK TRANSACTION [delete_cat_currency];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO