--tbl_printers.sql
--create
CREATE OR ALTER PROCEDURE [dbo].[create_tbl_printers]
    @ip varchar(15),
    @model varchar(20),
    @location varchar(20),
    @protocol varchar(20),
    @alias varchar(20),
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
            SAVE TRANSACTION [create_tbl_printers];
            DECLARE @errors varchar(max);
            DECLARE @id TABLE(id int);

            IF EXISTS(SELECT id FROM tbl_printers WHERE ip = @ip)
                SET @errors = CONCAT(@errors, 'IP ya registrada: ', @ip, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    INSERT INTO 
                        tbl_printers(dateCreated, dateModified, ip, model, location, protocol, alias)
                    OUTPUT inserted.id INTO @id
                    VALUES 
                        (GETDATE(), GETDATE(), @ip, @model, @location, @protocol, @alias)
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
            ROLLBACK TRANSACTION [create_tbl_printers];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[update_tbl_printers]
    @deviceId int,
    @ip varchar(15),
    @model varchar(20),
    @location varchar(20),
    @protocol varchar(20),
    @alias varchar(20),
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
            SAVE TRANSACTION [update_tbl_printers];
            DECLARE @errors varchar(max);
            DECLARE @currentIp varchar(15);
            SELECT @currentIp = ip FROM tbl_printers WHERE id = @deviceId

            IF NOT EXISTS(SELECT id FROM tbl_printers WHERE id = @deviceId)
                SET @errors = CONCAT(@errors, 'Dispositivo no encontrado: ', @deviceId, CHAR(13), CHAR(10));

            ELSE IF (@currentIp = @ip)
                SET @errors = CONCAT(@errors, 'La IP no puede ser la misma: ', @ip, CHAR(13), CHAR(10));

            ELSE IF (@currentIp <> @ip) AND EXISTS(SELECT ip FROM tbl_printers WHERE ip = @ip)
                SET @errors = CONCAT(@errors, 'IP ya registrada: ', @ip, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    UPDATE 
                        tbl_printers
                    SET
                        dateModified = GETDATE(),
                        ip = COALESCE(@ip, ip),
                        model = COALESCE(@model, model),
                        location = COALESCE(@location, location),
                        protocol = COALESCE(@protocol, protocol),
                        alias = COALESCE(@alias, alias)
                    WHERE 
                        id = @deviceId
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
            ROLLBACK TRANSACTION [update_tbl_printers];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_tbl_printers]
    @deviceId int,
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
            SAVE TRANSACTION [delete_tbl_printers];
            DECLARE @errors varchar(max);

            IF NOT EXISTS(SELECT id FROM tbl_printers WHERE id = @deviceId)
                SET @errors = CONCAT(@errors, 'Dispositivo no encontrado: ', @deviceId, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    DELETE FROM
                        tbl_printers
                    WHERE  
                        id = @deviceId
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
            ROLLBACK TRANSACTION [delete_tbl_printers];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO