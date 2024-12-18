-- Create Procedure for rel_location_label
CREATE OR ALTER PROCEDURE [dbo].[create_rel_location_label]
    @locationId INT,
    @labelId INT,
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
            SAVE TRANSACTION [create_rel_location_label];

        DECLARE @errors VARCHAR(MAX);
		DECLARE @id TABLE(id int);

        -- Removed Restriction
        -- IF EXISTS(SELECT id FROM rel_location_label WHERE locationId = @locationId AND labelId = @labelId)
        --     SET @errors = CONCAT(@errors, 'Relación ya registrada.', CHAR(13), CHAR(10));

        IF NOT EXISTS (SELECT id FROM tbl_location WHERE id = @locationId)
            SET @errors = CONCAT(@errors, 'Ubicación no encontrada, id: ', @locationId, CHAR(13), CHAR(10));

        IF NOT EXISTS (SELECT id FROM tbl_label WHERE id = @labelId)
            SET @errors = CONCAT(@errors, 'Etiqueta no encontrada, id: ', @labelId, CHAR(13), CHAR(10));

        IF @errors IS NULL
        BEGIN
            INSERT INTO rel_location_label (dateCreated, dateModified, locationId, labelId)
            OUTPUT INSERTED.id INTO @id
            VALUES (GETDATE(), GETDATE(), @locationId, @labelId);
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
        IF @xstate = 1 ROLLBACK TRANSACTION [create_rel_location_label];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH;
END;
GO

-- Delete Procedure for rel_location_label
CREATE OR ALTER PROCEDURE [dbo].[delete_rel_location_label]
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
            SAVE TRANSACTION [delete_rel_location_label];

        DECLARE @errors VARCHAR(MAX);

        IF NOT EXISTS (SELECT id FROM rel_location_label WHERE id = @id)
            SET @errors = CONCAT(@errors, 'Relación de ubicación y etiqueta no encontrada: ', @id, CHAR(13), CHAR(10));

        IF @errors IS NULL
        BEGIN
            DELETE FROM rel_location_label
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
        IF @xstate = 1 ROLLBACK TRANSACTION [delete_rel_location_label];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH;
END;
GO
