--cat_product.sql
--create
CREATE OR ALTER PROCEDURE [dbo].[create_cat_product]
    @name varchar(100),
    @unitsName varchar(50),
    @isSet bit,
    @idOut int = NULL OUTPUT
AS
SET NOCOUNT ON;
DECLARE @tranCount int;
SET @tranCount = @@TRANCOUNT;
BEGIN

    BEGIN TRY
        IF @tranCount = 0
            BEGIN TRANSACTION;
        ELSE
            SAVE TRANSACTION [create_cat_product];
        
        DECLARE @errors varchar(max);
        DECLARE @id TABLE(id int);

        IF EXISTS(SELECT id
    FROM cat_product
    WHERE name = @name)
            SET @errors = CONCAT(@errors, 'Catálogo de producto ya registrado: ', @name, CHAR(13), CHAR(10));

        IF(@errors IS NULL)
        BEGIN
        INSERT INTO 
                cat_product
            (dateCreated, dateModified, name, unitsName, isSet, status)
        OUTPUT inserted.id INTO @id
        VALUES
            (GETDATE(), GETDATE(), @name, @unitsName, @isSet, 1);

        SELECT TOP 1
            @idOut = id
        FROM @id;
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
            ROLLBACK TRANSACTION [create_cat_product];
        
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[update_cat_product]
    @productId int,
    @name varchar(100),
    @unitsName varchar(50),
    @isSet bit,
    @idOut int = NULL OUTPUT
AS
SET NOCOUNT ON;
DECLARE @tranCount int;
SET @tranCount = @@TRANCOUNT;
BEGIN

    BEGIN TRY
        IF @tranCount = 0
            BEGIN TRANSACTION;
        ELSE
            SAVE TRANSACTION [update_cat_product];
        
        DECLARE @errors varchar(max);
        DECLARE @currentName varchar(100);
        SELECT @currentName = name
    FROM cat_product
    WHERE id = @productId;

        IF NOT EXISTS(SELECT id
    FROM cat_product
    WHERE id = @productId)
            SET @errors = CONCAT(@errors, 'Catálogo de producto no encontrado: ', @name, CHAR(13), CHAR(10));

        ELSE IF (@currentName = @name)
            SET @errors = CONCAT(@errors, 'El nombre no puede ser el mismo: ', @name, CHAR(13), CHAR(10));

        ELSE IF (@currentName <> @name AND EXISTS(SELECT name
        FROM cat_product
        WHERE name = @name))
            SET @errors = CONCAT(@errors, 'Catálogo de producto ya registrado: ', @name, CHAR(13), CHAR(10));

        IF(@errors IS NULL)
        BEGIN
        UPDATE 
                cat_product
            SET
                dateModified = GETDATE(),
                name = COALESCE(@name, name),
                unitsName = COALESCE(@unitsName, unitsName),
                isSet = COALESCE(@isSet, isSet)
            WHERE 
                id = @productId;

        SELECT 1 AS affects_rows, NULL AS error, @productId AS id;
    END
        ELSE
        BEGIN
        SELECT 0 AS affects_rows, @errors AS error, @productId AS id;
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
            ROLLBACK TRANSACTION [update_cat_product];
        
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_cat_product]
    @productId int,
    @idOut int = NULL OUTPUT
AS
SET NOCOUNT ON;
DECLARE @tranCount int;
SET @tranCount = @@TRANCOUNT;
BEGIN

    BEGIN TRY
        IF @tranCount = 0
            BEGIN TRANSACTION;
        ELSE
            SAVE TRANSACTION [delete_cat_product];
        
        DECLARE @errors varchar(max);

        IF NOT EXISTS(SELECT id
    FROM cat_product
    WHERE id = @productId)
            SET @errors = CONCAT(@errors, 'Catálogo de producto no encontrado: ', @productId, CHAR(13), CHAR(10));

        IF(@errors IS NULL)
        BEGIN
        UPDATE
                cat_product
            SET
                status = 0
            WHERE  
                id = @productId;

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
            ROLLBACK TRANSACTION [delete_cat_product];
        
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO
