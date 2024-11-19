-- Create Procedure for tbl_location
CREATE OR ALTER PROCEDURE [dbo].[create_tbl_location]
    @principalModified VARCHAR(100),
    @nave VARCHAR(100),
    @section VARCHAR(100),
    @comment VARCHAR(250),
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
            SAVE TRANSACTION [create_tbl_location];

        DECLARE @errors VARCHAR(MAX);
		DECLARE @id TABLE(id int);

        IF @errors IS NULL
        BEGIN
            INSERT INTO tbl_location (dateCreated, dateModified, principalModified, nave, section, comment)
            OUTPUT INSERTED.id INTO @id
            VALUES (GETDATE(), GETDATE(), @principalModified, @nave, @section, @comment);
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
        IF @xstate = 1 ROLLBACK TRANSACTION [create_tbl_location];
        
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH;
END;
GO

-- Update Procedure for tbl_location
CREATE OR ALTER PROCEDURE [dbo].[update_tbl_location]
    @id INT,
    @principalModified VARCHAR(100) = NULL,
    @nave VARCHAR(100) = NULL,
    @section VARCHAR(100) = NULL,
    @comment VARCHAR(250) = NULL,
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
            SAVE TRANSACTION [update_tbl_location];

        DECLARE @errors VARCHAR(MAX);

        IF NOT EXISTS(SELECT id FROM tbl_location WHERE id = @id)
            SET @errors = CONCAT(@errors, 'Ubicación no encontrada, id: ', @id, CHAR(13), CHAR(10));

        IF @errors IS NULL
        BEGIN
            UPDATE tbl_location
            SET
                dateModified = GETDATE(),
                principalModified = COALESCE(@principalModified, principalModified),
                nave = COALESCE(@nave, nave),
                section = COALESCE(@section, section),
                comment = COALESCE(@comment, comment)
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
        IF @xstate = 1 ROLLBACK TRANSACTION [update_tbl_location];
        
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH;
END;
GO

-- Delete Procedure for tbl_location
CREATE OR ALTER PROCEDURE [dbo].[delete_tbl_location]
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
            SAVE TRANSACTION [delete_tbl_location];

        DECLARE @errors VARCHAR(MAX);

        IF NOT EXISTS(SELECT id FROM tbl_location WHERE id = @id)
            SET @errors = CONCAT(@errors, 'Ubicación no encontrada: ', @id, CHAR(13), CHAR(10));

        IF @errors IS NULL
        BEGIN
            DELETE FROM tbl_location
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
        IF @xstate = 1 ROLLBACK TRANSACTION [delete_tbl_location];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH;
END;
GO
