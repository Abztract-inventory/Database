--rel_product_attribute.sql
--create
CREATE OR ALTER PROCEDURE [dbo].[create_rel_product_attribute]
    @productId int, --cat_product
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
            SAVE TRANSACTION [create_rel_product_attribute];
            DECLARE @errors varchar(max);
            DECLARE @id TABLE(id int);

            IF EXISTS(SELECT id FROM rel_product_attribute WHERE productId = @productId AND attributeId = @attributeId)
                SET @errors = CONCAT(@errors, 'Relación ya registrada.', CHAR(13), CHAR(10));

            IF (@productId IS NOT NULL) AND NOT EXISTS(SELECT id FROM cat_product WHERE id = @productId)
                SET @errors = CONCAT(@errors, 'Catálogo de producto no encontrado.', CHAR(13), CHAR(10));
                
            IF (@attributeId IS NOT NULL) AND NOT EXISTS(SELECT id FROM tbl_attribute WHERE id = @attributeId)
                SET @errors = CONCAT(@errors, 'Atributo no encontrado.', CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    INSERT INTO 
                        rel_product_attribute(dateCreated, dateModified, productId, attributeId)
                    OUTPUT inserted.id INTO @id
                    VALUES 
                        (GETDATE(), GETDATE(), @productId, @attributeId)
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
            ROLLBACK TRANSACTION [create_rel_product_attribute];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_rel_product_attribute]
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
            SAVE TRANSACTION [delete_rel_product_attribute];
            DECLARE @errors varchar(max);

            IF NOT EXISTS(SELECT id FROM rel_product_attribute WHERE productId = @productId AND attributeId = @attributeId)
                SET @errors = CONCAT(@errors, 'Relación no encontrada.', CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    DELETE FROM
                        rel_product_attribute
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
            ROLLBACK TRANSACTION [delete_rel_product_attribute];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO