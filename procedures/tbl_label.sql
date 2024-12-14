-- tbl_label.sql

-- generate
CREATE OR ALTER PROCEDURE [dbo].[generate_label]
    @baseString VARCHAR(50),
    @truncateLength INT,
    @labelId INT = NULL OUTPUT,
    @generatedLabel VARCHAR(50) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @tranCount INT = @@TRANCOUNT;
    DECLARE @xstate INT;
    DECLARE @errors VARCHAR(MAX) = NULL;
    DECLARE @currentLength INT = @truncateLength;
    DECLARE @truncatedLabel VARCHAR(50);

    BEGIN TRY
        IF @tranCount = 0
            BEGIN TRANSACTION;
        ELSE
            SAVE TRANSACTION [generate_label];

        -- Elimina espacios en blanco al inicio y al final
        DECLARE @trimmedBaseString VARCHAR(50) = LTRIM(RTRIM(@baseString)); 

        -- Validaciones iniciales
        IF @trimmedBaseString IS NULL OR LEN(@trimmedBaseString) = 0
            SET @errors = CONCAT(@errors, 'La etiqueta base no puede estar vacía.', CHAR(13), CHAR(10));

        IF @truncateLength <= 0
            SET @errors = CONCAT(@errors, 'La longitud de truncado debe ser mayor que cero.', CHAR(13), CHAR(10));

        IF @truncateLength > LEN(@trimmedBaseString)
            SET @errors = CONCAT(@errors, 'La longitud de truncado no puede ser mayor que la longitud de la etiqueta base.', CHAR(13), CHAR(10));

        -- Salida temprana si hay errores
        IF @errors IS NOT NULL
            GOTO lbexit;

        WHILE @currentLength <= LEN(@trimmedBaseString) AND @errors IS NULL
        BEGIN
        SET @truncatedLabel = LEFT(@trimmedBaseString, @currentLength);

        IF NOT EXISTS (
                SELECT 1
        FROM tbl_label
        WHERE label = @truncatedLabel
            )
            BEGIN
            INSERT INTO tbl_label
                (dateCreated, dateModified, label)
            VALUES
                (GETDATE(), GETDATE(), @truncatedLabel);

            -- Captura el ID generado
            SET @labelId = SCOPE_IDENTITY();
            SET @generatedLabel = @truncatedLabel;

            SELECT 1 AS affects_rows, @errors AS error, @labelId AS id, @generatedLabel AS label;
            GOTO lbexit;
        END

        SET @currentLength = @currentLength + 1;
    END

        SET @errors = CONCAT(@errors, 'No se pudo generar una etiqueta única a partir de la etiqueta base proporcionada.', CHAR(13), CHAR(10));

        IF(@errors IS NOT NULL)
            SELECT 0 AS affects_rows, @errors AS error, NULL AS id, NULL AS label;

        lbexit:
            IF @tranCount = 0
                COMMIT;
    END TRY
    BEGIN CATCH
        SELECT @xstate = XACT_STATE();
        IF @xstate = -1
            ROLLBACK;
        IF @xstate = 1
            ROLLBACK TRANSACTION [generate_label];

        DECLARE @message VARCHAR(4000) = ERROR_MESSAGE();
        SELECT 0 AS affects_rows, @message AS error, NULL AS id, NULL AS label;
    END CATCH
END
GO

-- create
CREATE OR ALTER PROCEDURE [dbo].[create_tbl_label]
    @label VARCHAR(50),
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
            SAVE TRANSACTION [create_tbl_label];

        DECLARE @errors VARCHAR(MAX);
        DECLARE @id TABLE(id INT);

        IF EXISTS (SELECT id
    FROM tbl_label
    WHERE label = @label)
            SET @errors = CONCAT(@errors, 'Etiqueta ya registrada: ', @label, CHAR(13), CHAR(10));

        IF (@errors IS NULL)
        BEGIN
        INSERT INTO tbl_label
            (dateCreated, dateModified, label)
        OUTPUT inserted.id INTO @id
        VALUES
            (GETDATE(), GETDATE(), @label);

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
        DECLARE @error INT, @message VARCHAR(4000), @xstate INT;
        SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();

        IF @xstate = -1
            ROLLBACK;
        IF @xstate = 1
            ROLLBACK TRANSACTION [create_tbl_label];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

-- update
CREATE OR ALTER PROCEDURE [dbo].[update_tbl_label]
    @labelId INT,
    @newLabel VARCHAR(50),
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
            SAVE TRANSACTION [update_tbl_label];

        DECLARE @errors VARCHAR(MAX);
        DECLARE @currentLabel VARCHAR(50);
        DECLARE @id TABLE(id INT);

        -- Verificar si el registro existe
        IF NOT EXISTS (SELECT id
    FROM tbl_label
    WHERE id = @labelId)
            SET @errors = CONCAT(@errors, 'Etiqueta no encontrada: ', @labelId, CHAR(13), CHAR(10));
        ELSE
            SELECT @currentLabel = label
    FROM tbl_label
    WHERE id = @labelId;

        -- Verificar si el nuevo label es el mismo que el actual
        IF (@currentLabel = @newLabel)
            SET @errors = CONCAT(@errors, 'El valor de la etiqueta no puede ser el mismo: ', @newLabel, CHAR(13), CHAR(10));

        -- Verificar si el nuevo label ya existe
        IF (@currentLabel <> @newLabel) AND EXISTS (SELECT id
        FROM tbl_label
        WHERE label = @newLabel)
            SET @errors = CONCAT(@errors, 'Etiqueta ya registrada: ', @newLabel, CHAR(13), CHAR(10));

        IF (@errors IS NULL)
        BEGIN
        UPDATE tbl_label
            SET
                dateModified = GETDATE(),
                label = @newLabel
            OUTPUT inserted.id INTO @id
            WHERE id = @labelId;

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
        DECLARE @error INT, @message VARCHAR(4000), @xstate INT;
        SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();

        IF @xstate = -1
            ROLLBACK;
        IF @xstate = 1
            ROLLBACK TRANSACTION [update_tbl_label];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

-- delete
CREATE OR ALTER PROCEDURE [dbo].[delete_tbl_label]
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
            SAVE TRANSACTION [delete_tbl_label];

        DECLARE @errors VARCHAR(MAX);

        IF NOT EXISTS (SELECT id
    FROM tbl_label
    WHERE id = @labelId)
            SET @errors = CONCAT(@errors, 'Etiqueta no encontrada: ', @labelId, CHAR(13), CHAR(10));

        IF (@errors IS NULL)
        BEGIN
        DELETE FROM tbl_label
            WHERE id = @labelId;

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
        DECLARE @error INT, @message VARCHAR(4000), @xstate INT;
        SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();

        IF @xstate = -1
            ROLLBACK;
        IF @xstate = 1
            ROLLBACK TRANSACTION [delete_tbl_label];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO