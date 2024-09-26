--cat_manufacturer.sql
--create
CREATE OR ALTER PROCEDURE [dbo].[create_cat_manufacturer]
    @manufacturerName varchar(100),
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
            SAVE TRANSACTION [create_cat_manufacturer];
            DECLARE @errors varchar(max);
            DECLARE @id TABLE(id int);

            IF EXISTS(SELECT id FROM cat_manufacturer WHERE name = @manufacturerName)
                SET @errors = CONCAT(@errors, 'Fabricante ya registrado: ', @manufacturerName, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    INSERT INTO 
                        cat_manufacturer(dateCreated, dateModified, name)
                    OUTPUT inserted.id INTO @id
                    VALUES 
                        (GETDATE(), GETDATE(), @manufacturerName)
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
            ROLLBACK TRANSACTION [create_cat_manufacturer];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[update_cat_manufacturer]
    @manufacturerId int,
    @manufacturerName varchar(100),
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
            SAVE TRANSACTION [update_cat_manufacturer];
            DECLARE @errors varchar(max);
            DECLARE @currentName varchar(100);
            SELECT @currentName = name FROM cat_manufacturer WHERE id = @manufacturerId

            IF NOT EXISTS(SELECT id FROM cat_manufacturer WHERE id = @manufacturerId)
                SET @errors = CONCAT(@errors, 'Fabricante no encontrado: ', @manufacturerName, CHAR(13), CHAR(10));

            ELSE IF (@currentName = @manufacturerName)
                SET @errors = CONCAT(@errors, 'El nombre no puede ser el mismo: ', @manufacturerName, CHAR(13), CHAR(10));

            ELSE IF (@currentName <> @manufacturerName) AND EXISTS(SELECT name FROM cat_manufacturer WHERE name = @manufacturerName)
                SET @errors = CONCAT(@errors, 'Fabricante ya registrado: ', @manufacturerName, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    UPDATE 
                        cat_manufacturer
                    SET
                        name = @manufacturerName,
                        dateModified = GETDATE()
                    WHERE 
                        id = @manufacturerId
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
            ROLLBACK TRANSACTION [update_cat_manufacturer];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_cat_manufacturer]
    @manufacturerId int,
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
            SAVE TRANSACTION [delete_cat_manufacturer];
            DECLARE @errors varchar(max);

            IF NOT EXISTS(SELECT id FROM cat_manufacturer WHERE id = @manufacturerId)
                SET @errors = CONCAT(@errors, 'Fabricante no encontrado: ', @manufacturerId, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    DELETE FROM
                        cat_manufacturer
                    WHERE  
                        id = @manufacturerId
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
            ROLLBACK TRANSACTION [delete_cat_manufacturer];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO