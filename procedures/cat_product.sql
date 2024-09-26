--cat_product.sql
--create
CREATE OR ALTER PROCEDURE [dbo].[createCatProduct]
    @name varchar(100),
    @unitsName varchar(50),
    @isSet bit,
    @statusId int,
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
            SAVE TRANSACTION [createCatProduct];
            DECLARE @errors varchar(max);
            DECLARE @id TABLE(id int);

            IF EXISTS(SELECT id FROM cat_product WHERE name = @name)
                SET @errors = CONCAT(@errors, 'Catálogo de producto ya registrado: ', @name, CHAR(13), CHAR(10));

            IF NOT EXISTS(SELECT id FROM cat_status WHERE id = @statusId)
                SET @errors = CONCAT(@errors, 'Estatus no encontrado: ', @statusId, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    INSERT INTO 
                        cat_product(dateCreated, dateModified, name, unitsName, isSet, statusId)
                    OUTPUT inserted.id INTO @id
                    VALUES 
                        (GETDATE(), GETDATE(), @name, @unitsName, @isSet, @statusId)
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
            ROLLBACK TRANSACTION [createCatProduct];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[updateCatProduct]
    @productId int,
    @name varchar(100),
    @unitsName varchar(50),
    @isSet bit,
    @statusId int,
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
            SAVE TRANSACTION [updateCatProduct];
            DECLARE @errors varchar(max);
            DECLARE @currentName varchar(100);
            SELECT @currentName = name FROM cat_product WHERE id = @productId

            IF NOT EXISTS(SELECT id FROM cat_product WHERE id = @productId)
                SET @errors = CONCAT(@errors, 'Catálogo de producto no encontrado: ', @name, CHAR(13), CHAR(10));

            IF (@statusId IS NOT NULL) AND NOT EXISTS(SELECT id FROM cat_status WHERE id = @statusId)
                SET @errors = CONCAT(@errors, 'Estatus no encontrado: ', @statusId, CHAR(13), CHAR(10));

            ELSE IF (@currentName = @name)
                SET @errors = CONCAT(@errors, 'El nombre no puede ser el mismo: ', @name, CHAR(13), CHAR(10));

            ELSE IF (@currentName <> @name) AND EXISTS(SELECT name FROM cat_product WHERE name = @name)
                SET @errors = CONCAT(@errors, 'Catálogo de producto ya registrado: ', @name, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    UPDATE 
                        cat_product
                    SET
                        dateModified = GETDATE(),
                        name = COALESCE(@name, name),
                        unitsName = COALESCE(@unitsName, unitsName),
                        isSet = COALESCE(@isSet, isSet),
                        statusId = COALESCE(@statusId, statusId)
                    WHERE 
                        id = @productId
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
            ROLLBACK TRANSACTION [updateCatProduct];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[deleteCatProduct]
    @productId int,
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
            SAVE TRANSACTION [deleteCatProduct];
            DECLARE @errors varchar(max);

            IF NOT EXISTS(SELECT id FROM cat_product WHERE id = @productId)
                SET @errors = CONCAT(@errors, 'Catálogo de producto no encontrado: ', @productId, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    DELETE FROM
                        cat_product
                    WHERE  
                        id = @productId
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
            ROLLBACK TRANSACTION [deleteCatProduct];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO