--cat_material.sql
--create
CREATE OR ALTER PROCEDURE [dbo].[createCatMaterial]
    @materialName varchar(100),
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
            SAVE TRANSACTION [createCatMaterial];
            DECLARE @errors varchar(max);
            DECLARE @id TABLE(id int);

            IF EXISTS(SELECT id FROM cat_material WHERE name = @materialName)
                SET @errors = CONCAT(@errors, 'Material ya registrado: ', @materialName, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    INSERT INTO 
                        cat_material(dateCreated, dateModified, name)
                    OUTPUT inserted.id INTO @id
                    VALUES 
                        (GETDATE(), GETDATE(), @materialName)
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
            ROLLBACK TRANSACTION [createCatMaterial];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[updateCatMaterial]
    @materialId int,
    @materialName varchar(100),
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
            SAVE TRANSACTION [updateCatMaterial];
            DECLARE @errors varchar(max);
            DECLARE @currentName varchar(100);
            SELECT @currentName = name FROM cat_material WHERE id = @materialId

            IF NOT EXISTS(SELECT id FROM cat_material WHERE id = @materialId)
                SET @errors = CONCAT(@errors, 'Material no encontrado: ', @materialName, CHAR(13), CHAR(10));

            ELSE IF (@currentName = @materialName)
                SET @errors = CONCAT(@errors, 'El nombre no puede ser el mismo: ', @materialName, CHAR(13), CHAR(10));

            ELSE IF (@currentName <> @materialName) AND EXISTS(SELECT name FROM cat_material WHERE name = @materialName)
                SET @errors = CONCAT(@errors, 'Material ya registrado: ', @materialName, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    UPDATE 
                        cat_material
                    SET
                        name = @materialName,
                        dateModified = GETDATE()
                    WHERE 
                        id = @materialId
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
            ROLLBACK TRANSACTION [updateCatMaterial];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[deleteCatMaterial]
    @materialId int,
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
            SAVE TRANSACTION [deleteCatMaterial];
            DECLARE @errors varchar(max);

            IF NOT EXISTS(SELECT id FROM cat_material WHERE id = @materialId)
                SET @errors = CONCAT(@errors, 'Material no encontrado: ', @materialId, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    DELETE FROM
                        cat_material
                    WHERE  
                        id = @materialId
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
            ROLLBACK TRANSACTION [deleteCatMaterial];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO