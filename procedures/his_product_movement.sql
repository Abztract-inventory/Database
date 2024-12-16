-- Create Procedure for his_product_movement
CREATE OR ALTER PROCEDURE [dbo].[create_his_product_movement]
    @principalModified VARCHAR(100),
    @labelId INT,
    @quantity FLOAT,
    @unitValue FLOAT,
    @reason VARCHAR(500),
    @inFlag BIT,
    @batchId INT,
    @idOut INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @tranCount INT;
    SET @tranCount = @@TRANCOUNT;
    BEGIN TRY
        IF @tranCount = 0
            BEGIN TRANSACTION;
        ELSE
            SAVE TRANSACTION [create_his_product_movement];

        DECLARE @errors VARCHAR(MAX);
		DECLARE @id TABLE(id int);

        IF NOT EXISTS (SELECT id
    FROM tbl_label
    WHERE id = @labelId)
            SET @errors = CONCAT(@errors, 'Etiqueta no encontrada, id: ', @labelId, CHAR(13), CHAR(10));

        IF (@batchId IS NOT NULL) AND NOT EXISTS (SELECT id
        FROM tbl_production_batch
        WHERE id = @batchId)
            SET @errors = CONCAT(@errors, 'Lote de producción no encontrado, id: ', @batchId, CHAR(13), CHAR(10));

        IF @errors IS NULL
        BEGIN
        INSERT INTO his_product_movement
            (dateCreated, dateModified, principalModified, labelId, quantity, unitValue, reason, inFlag, batchId)
        OUTPUT INSERTED.id INTO @id
        VALUES
            (GETDATE(), GETDATE(), @principalModified, @labelId, @quantity, @unitValue, @reason, @inFlag, @batchId);
        SELECT TOP 1
            @idOut = id
        FROM @id
        SELECT 1 AS affects_rows, NULL AS error, @idOut AS id;
    END
        ELSE
            SELECT 0 AS affects_rows, @errors AS error, @idOut AS id;

        IF @tranCount = 0
            COMMIT;
    END TRY
    BEGIN CATCH
        DECLARE @error INT, @message VARCHAR(4000), @xstate INT;
        SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();

        IF @xstate = -1 ROLLBACK;
        IF @xstate = 1 ROLLBACK TRANSACTION [create_his_product_movement];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH;
END;
GO

-- Update Procedure for his_product_movement
CREATE OR ALTER PROCEDURE [dbo].[update_his_product_movement]
    @id INT,
    @principalModified VARCHAR(100) = NULL,
    @labelId INT = NULL,
    @quantity FLOAT = NULL,
    @unitValue FLOAT = NULL,
    @reason VARCHAR(500) = NULL,
    @inFlag BIT = NULL,
    @batchId INT = NULL,
    @idOut INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @tranCount INT;
    SET @tranCount = @@TRANCOUNT;
    BEGIN TRY
        IF @tranCount = 0
            BEGIN TRANSACTION;
        ELSE
            SAVE TRANSACTION [update_his_product_movement];

        DECLARE @errors VARCHAR(MAX);

        IF NOT EXISTS (SELECT id
    FROM his_product_movement
    WHERE id = @id)
            SET @errors = CONCAT(@errors, 'Movimiento de producto no encontrado, id: ', @id, CHAR(13), CHAR(10));

        IF (@labelId IS NOT NULL) AND NOT EXISTS (SELECT id
        FROM tbl_label
        WHERE id = @labelId)
            SET @errors = CONCAT(@errors, 'Etiqueta no encontrada, id: ', @labelId, CHAR(13), CHAR(10));

        IF (@batchId IS NOT NULL) AND NOT EXISTS (SELECT id
        FROM tbl_production_batch
        WHERE id = @batchId)
            SET @errors = CONCAT(@errors, 'Lote de producción no encontrado, id: ', @batchId, CHAR(13), CHAR(10));

        IF @errors IS NULL
        BEGIN
        UPDATE his_product_movement
            SET
                dateModified = GETDATE(),
                principalModified = COALESCE(@principalModified, principalModified),
                labelId = COALESCE(@labelId, labelId),
                quantity = COALESCE(@quantity, quantity),
                unitValue = COALESCE(@unitValue, unitValue),
                reason = COALESCE(@reason, reason),
                inFlag = COALESCE(@inFlag, inFlag),
                batchId = COALESCE(@batchId, batchId)
            WHERE id = @id;

        SELECT 1 AS affects_rows, NULL AS error, @idOut AS id;
    END
        ELSE
            SELECT 0 AS affects_rows, @errors AS error, @idOut AS id;

        IF @tranCount = 0
            COMMIT;
    END TRY
    BEGIN CATCH
        DECLARE @error INT, @message VARCHAR(4000), @xstate INT;
        SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();

        IF @xstate = -1 ROLLBACK;
        IF @xstate = 1 ROLLBACK TRANSACTION [update_his_product_movement];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH;
END;
GO

-- Delete Procedure for his_product_movement
CREATE OR ALTER PROCEDURE [dbo].[delete_his_product_movement]
    @id INT,
    @idOut INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @tranCount INT;
    SET @tranCount = @@TRANCOUNT;
    BEGIN TRY
        IF @tranCount = 0
            BEGIN TRANSACTION;
        ELSE
            SAVE TRANSACTION [delete_his_product_movement];

        DECLARE @errors VARCHAR(MAX);

        IF NOT EXISTS (SELECT id
    FROM his_product_movement
    WHERE id = @id)
            SET @errors = CONCAT(@errors, 'Movimiento de producto no encontrado: ', @id, CHAR(13), CHAR(10));

        IF @errors IS NULL
        BEGIN
        DELETE FROM his_product_movement
            WHERE id = @id;

        SELECT 1 AS affects_rows, NULL AS error, @idOut AS id;
    END
        ELSE
            SELECT 0 AS affects_rows, @errors AS error, @idOut AS id;

        IF @tranCount = 0
            COMMIT;
    END TRY
    BEGIN CATCH
        DECLARE @error INT, @message VARCHAR(4000), @xstate INT;
        SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();

        IF @xstate = -1 ROLLBACK;
        IF @xstate = 1 ROLLBACK TRANSACTION [delete_his_product_movement];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH;
END;
GO
