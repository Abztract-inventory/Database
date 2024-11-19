-- Create Procedure for tbl_production_batch
CREATE OR ALTER PROCEDURE [dbo].[create_tbl_production_batch]
    @machineId INT,
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
            SAVE TRANSACTION [create_tbl_production_batch];

        DECLARE @errors VARCHAR(MAX);
		DECLARE @id TABLE(id int);

        IF NOT EXISTS (SELECT id FROM cat_machine WHERE id = @machineId)
            SET @errors = CONCAT(@errors, 'Máquina no encontrada, id: ', @machineId, CHAR(13), CHAR(10));

        IF @errors IS NULL
        BEGIN
            INSERT INTO tbl_production_batch (dateCreated, dateModified, machineId)
            OUTPUT INSERTED.id INTO @id
            VALUES (GETDATE(), GETDATE(), @machineId);
			SELECT TOP 1 @idOut = id FROM @id
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
        IF @xstate = 1 ROLLBACK TRANSACTION [create_tbl_production_batch];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH;
END;
GO

-- Update Procedure for tbl_production_batch
CREATE OR ALTER PROCEDURE [dbo].[update_tbl_production_batch]
    @id INT,
    @machineId INT = NULL,
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
            SAVE TRANSACTION [update_tbl_production_batch];

        DECLARE @errors VARCHAR(MAX);

        IF NOT EXISTS (SELECT id FROM tbl_production_batch WHERE id = @id)
            SET @errors = CONCAT(@errors, 'Lote de producción no encontrado, id: ', @id, CHAR(13), CHAR(10));

        IF (@machineId IS NOT NULL) AND NOT EXISTS (SELECT id FROM cat_machine WHERE id = @machineId)
            SET @errors = CONCAT(@errors, 'Máquina no encontrada, id: ', @machineId, CHAR(13), CHAR(10));

        IF @errors IS NULL
        BEGIN
            UPDATE tbl_production_batch
            SET
                dateModified = GETDATE(),
                machineId = COALESCE(@machineId, machineId)
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
        IF @xstate = 1 ROLLBACK TRANSACTION [update_tbl_production_batch];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH;
END;
GO

-- Delete Procedure for tbl_production_batch
CREATE OR ALTER PROCEDURE [dbo].[delete_tbl_production_batch]
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
            SAVE TRANSACTION [delete_tbl_production_batch];

        DECLARE @errors VARCHAR(MAX);

        IF NOT EXISTS (SELECT id FROM tbl_production_batch WHERE id = @id)
            SET @errors = CONCAT(@errors, 'Lote de producción no encontrado: ', @id, CHAR(13), CHAR(10));

        IF @errors IS NULL
        BEGIN
            DELETE FROM tbl_production_batch
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
        IF @xstate = 1 ROLLBACK TRANSACTION [delete_tbl_production_batch];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH;
END;
GO
