-- Create Procedure for cat_machine
CREATE OR ALTER PROCEDURE [dbo].[create_cat_machine]
    @principalModified VARCHAR(100),
    @locationId INT,
    @machine VARCHAR(150),
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
            SAVE TRANSACTION [create_cat_machine];

        DECLARE @errors VARCHAR(MAX);
		DECLARE @id TABLE(id int);

        IF NOT EXISTS (SELECT id FROM tbl_location WHERE id = @locationId)
            SET @errors = CONCAT(@errors, 'Ubicación no encontrada, id: ', @locationId, CHAR(13), CHAR(10));

        IF @errors IS NULL
        BEGIN
            INSERT INTO 
				cat_machine (dateCreated, dateModified, principalModified, locationId, machine)
            OUTPUT INSERTED.id INTO @id
            VALUES 
				(GETDATE(), GETDATE(), @principalModified, @locationId, @machine);
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
        IF @xstate = 1 ROLLBACK TRANSACTION [create_cat_machine];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH;
END;
GO

-- Update Procedure for cat_machine
CREATE OR ALTER PROCEDURE [dbo].[update_cat_machine]
    @id INT,
    @principalModified VARCHAR(100) = NULL,
    @locationId INT = NULL,
    @machine VARCHAR(150) = NULL,
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
            SAVE TRANSACTION [update_cat_machine];

        DECLARE @errors VARCHAR(MAX);

        IF NOT EXISTS (SELECT id FROM cat_machine WHERE id = @id)
            SET @errors = CONCAT(@errors, 'Máquina no encontrada, id: ', @id, CHAR(13), CHAR(10));

        IF (@locationId IS NOT NULL) AND NOT EXISTS (SELECT id FROM tbl_location WHERE id = @locationId)
            SET @errors = CONCAT(@errors, 'Ubicación no encontrada, id: ', @locationId, CHAR(13), CHAR(10));

        IF @errors IS NULL
        BEGIN
            UPDATE cat_machine
            SET
                dateModified = GETDATE(),
                principalModified = COALESCE(@principalModified, principalModified),
                locationId = COALESCE(@locationId, locationId),
                machine = COALESCE(@machine, machine)
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
        IF @xstate = 1 ROLLBACK TRANSACTION [update_cat_machine];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH;
END;
GO

-- Delete Procedure for cat_machine
CREATE OR ALTER PROCEDURE [dbo].[delete_cat_machine]
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
            SAVE TRANSACTION [delete_cat_machine];

        DECLARE @errors VARCHAR(MAX);

        IF NOT EXISTS (SELECT id FROM cat_machine WHERE id = @id)
            SET @errors = CONCAT(@errors, 'Máquina no encontrada: ', @id, CHAR(13), CHAR(10));

        IF @errors IS NULL
        BEGIN
            DELETE FROM 
				cat_machine
            WHERE 
				id = @id;

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
        IF @xstate = 1 ROLLBACK TRANSACTION [delete_cat_machine];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH;
END;
GO
