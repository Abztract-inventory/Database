--tbl_value.sql
--create
CREATE OR ALTER PROCEDURE [dbo].[create_tbl_value]
    @value varchar(max),
    @productId int, --tbl_product
    @attributeId int,
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
            SAVE TRANSACTION [create_tbl_value];
            DECLARE @errors varchar(max);
            DECLARE @id TABLE(id int);

            IF EXISTS(SELECT id FROM tbl_value WHERE productId = @productId AND attributeId = @attributeId)
                SET @errors = CONCAT(@errors, 'Valor ya registrado.', CHAR(13), CHAR(10));

            IF (@productId IS NOT NULL) AND NOT EXISTS(SELECT id FROM tbl_product WHERE id = @productId)
                SET @errors = CONCAT(@errors, 'Producto no encontrado.', CHAR(13), CHAR(10));
                
            IF (@attributeId IS NOT NULL) AND NOT EXISTS(SELECT id FROM tbl_attribute WHERE id = @attributeId)
                SET @errors = CONCAT(@errors, 'Atributo no encontrado.', CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    INSERT INTO 
                        tbl_value(dateCreated, dateModified, value, productId, attributeId)
                    OUTPUT inserted.id INTO @id
                    VALUES 
                        (GETDATE(), GETDATE(), @value, @productId, @attributeId)
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
            ROLLBACK TRANSACTION [create_tbl_value];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[update_tbl_value]
    @value varchar(max),
    @productId int,
    @attributeId int,
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
            SAVE TRANSACTION [update_tbl_value];
            DECLARE @errors varchar(max);

            IF NOT EXISTS(SELECT id FROM tbl_value WHERE productId = @productId AND attributeId = @attributeId)
                SET @errors = CONCAT(@errors, 'Valor no encontrado: ', @productId, ', ', @attributeId, CHAR(13), CHAR(10));

            IF (@productId IS NOT NULL) AND NOT EXISTS(SELECT id FROM tbl_product WHERE id = @productId)
                SET @errors = CONCAT(@errors, 'Producto no encontrado.', CHAR(13), CHAR(10));
                
            IF (@attributeId IS NOT NULL) AND NOT EXISTS(SELECT id FROM tbl_attribute WHERE id = @attributeId)
                SET @errors = CONCAT(@errors, 'Atributo no encontrado.', CHAR(13), CHAR(10));
                
            ELSE IF EXISTS(SELECT id FROM tbl_value WHERE value = @value AND productId = @productId AND attributeId = @attributeId)
                SET @errors = CONCAT(@errors, 'Valor ya registrado.', CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    UPDATE 
                        tbl_value
                    SET
                        value = COALESCE(@value, value),
                        productId = COALESCE(@productId, productId),
                        attributeId = COALESCE(@attributeId, attributeId),
                        dateModified = GETDATE()
                    WHERE 
                        productId = @productId AND attributeId = @attributeId
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
            ROLLBACK TRANSACTION [update_tbl_value];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_tbl_value]
    @productId int,
    @attributeId int,
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
            SAVE TRANSACTION [delete_tbl_value];
            DECLARE @errors varchar(max);

            IF (@productId IS NOT NULL) AND NOT EXISTS(SELECT id FROM tbl_product WHERE id = @productId)
                SET @errors = CONCAT(@errors, 'Producto no encontrado.', CHAR(13), CHAR(10));
                
            IF (@attributeId IS NOT NULL) AND NOT EXISTS(SELECT id FROM tbl_attribute WHERE id = @attributeId)
                SET @errors = CONCAT(@errors, 'Atributo no encontrado.', CHAR(13), CHAR(10));

            IF NOT EXISTS(SELECT id FROM tbl_value WHERE productId = @productId AND attributeId = @attributeId)
                SET @errors = CONCAT(@errors, 'Valor no encontrado: ', @productId, ', ', @attributeId, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    DELETE FROM
                        tbl_value
                    WHERE  
                        productId = @productId AND attributeId = @attributeId
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
            ROLLBACK TRANSACTION [delete_tbl_value];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO