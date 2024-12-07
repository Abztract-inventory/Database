CREATE OR ALTER PROCEDURE [dbo].[create_tbl_product]
    @catProductId int,
    --cat_product
    @documentNumber varchar(30),
    @supplierNumber varchar(30),
    @materialId int,
    @grammage float,
    @width float,
    @length float,
    @height float,
    @isPrinted bit,
    @isWaxed bit,
    @companyId int,
    @cost float,
    @currencyId int,
    @exchangeRate float,
    @specificAttribute varchar(MAX),
    @manufacturerId int,
    @labelId int = NULL,
    -- Nuevo campo
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
            SAVE TRANSACTION [create_tbl_product];
            DECLARE @errors varchar(max);
            DECLARE @id TABLE(id int);

            IF NOT EXISTS(SELECT id
    FROM cat_product
    WHERE id = @catProductId)
                SET @errors = CONCAT(@errors, 'Catálogo de producto no encontrado.', CHAR(13), CHAR(10));

            IF NOT EXISTS(SELECT id
    FROM cat_material
    WHERE id = @materialId)
                SET @errors = CONCAT(@errors, 'Material no encontrado.', CHAR(13), CHAR(10));

            IF NOT EXISTS(SELECT id
    FROM cat_company
    WHERE id = @companyId)
                SET @errors = CONCAT(@errors, 'Empresa no encontrada.', CHAR(13), CHAR(10));

            IF NOT EXISTS(SELECT id
    FROM cat_currency
    WHERE id = @currencyId)
                SET @errors = CONCAT(@errors, 'Tipo de cambio no encontrado.', CHAR(13), CHAR(10));

            IF NOT EXISTS(SELECT id
    FROM cat_manufacturer
    WHERE id = @manufacturerId)
                SET @errors = CONCAT(@errors, 'Fabricante no encontrado.', CHAR(13), CHAR(10));

            IF NOT EXISTS(SELECT id
    FROM tbl_label
    WHERE id = @labelId)
                SET @errors = CONCAT(@errors, 'Etiqueta no encontrada.', CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
        INSERT INTO 
                        tbl_product
            (
            dateCreated,
            dateModified,
            status,
            productId,
            documentNumber,
            supplierNumber,
            materialId,
            grammage,
            width,
            length,
            height,
            isPrinted,
            isWaxed,
            companyId,
            cost,
            currencyId,
            exchangeRate,
            specificAttribute,
            manufacturerId,
            labelId -- Nuevo campo
            )
        OUTPUT inserted.id INTO @id
        VALUES
            (
                GETDATE(),
                GETDATE(),
                1,
                @catProductId,
                @documentNumber,
                @supplierNumber,
                @materialId,
                @grammage,
                @width,
                @length,
                @height,
                @isPrinted,
                @isWaxed,
                @companyId,
                @cost,
                @currencyId,
                @exchangeRate,
                @specificAttribute,
                @manufacturerId,
                @labelId -- Nuevo campo
                        )
        SELECT TOP 1
            @idOut = id
        FROM @id
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
            ROLLBACK TRANSACTION [create_tbl_product];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[update_tbl_product]
    @productId int,
    @catProductId int,
    --cat_product
    @documentNumber varchar(30),
    @supplierNumber varchar(30),
    @materialId int,
    @grammage float,
    @width float,
    @length float,
    @height float,
    @isPrinted bit,
    @isWaxed bit,
    @companyId int,
    @cost float,
    @currencyId int,
    @exchangeRate float,
    @specificAttribute varchar(MAX),
    @manufacturerId int,
    @labelId int = NULL,
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
            SAVE TRANSACTION [update_tbl_product];

            DECLARE @errors varchar(max);

            IF NOT EXISTS(SELECT id
    FROM tbl_product
    WHERE id = @productId)
                SET @errors = CONCAT(@errors, 'Producto no encontrado, id: ', @productId, CHAR(13), CHAR(10));

            IF (@catProductId IS NOT NULL) AND NOT EXISTS(SELECT id
        FROM cat_product
        WHERE id = @catProductId)
                SET @errors = CONCAT(@errors, 'Catálogo de producto no encontrado.', CHAR(13), CHAR(10));

            IF (@materialId IS NOT NULL) AND NOT EXISTS(SELECT id
        FROM cat_material
        WHERE id = @materialId)
                SET @errors = CONCAT(@errors, 'Material no encontrado.', CHAR(13), CHAR(10));

            IF (@companyId IS NOT NULL) AND NOT EXISTS(SELECT id
        FROM cat_company
        WHERE id = @companyId)
                SET @errors = CONCAT(@errors, 'Empresa no encontrada.', CHAR(13), CHAR(10));

            IF (@currencyId IS NOT NULL) AND NOT EXISTS(SELECT id
        FROM cat_currency
        WHERE id = @currencyId)
                SET @errors = CONCAT(@errors, 'Tipo de cambio no encontrado.', CHAR(13), CHAR(10));

            IF (@manufacturerId IS NOT NULL) AND NOT EXISTS(SELECT id
        FROM cat_manufacturer
        WHERE id = @manufacturerId)
                SET @errors = CONCAT(@errors, 'Fabricante no encontrado.', CHAR(13), CHAR(10));
            
            IF (@labelId IS NOT NULL) AND NOT EXISTS(SELECT id
        FROM tbl_label
        WHERE id = @labelId)
                SET @errors = CONCAT(@errors, 'Etiqueta no encontrada.', CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
        UPDATE 
                        tbl_product
                    SET
                        dateModified = GETDATE(),
                        productId = COALESCE(@catProductId, productId),
                        documentNumber = COALESCE(@documentNumber, documentNumber),
                        supplierNumber = COALESCE(@supplierNumber, supplierNumber),
                        materialId = COALESCE(@materialId, materialId),
                        grammage = COALESCE(@grammage, grammage),
                        width = COALESCE(@width, width),
                        length = COALESCE(@length, length),
                        height = COALESCE(@height, height),
                        isPrinted = COALESCE(@isPrinted, isPrinted),
                        isWaxed = COALESCE(@isWaxed, isWaxed),
                        companyId = COALESCE(@companyId, companyId),
                        cost = COALESCE(@cost, cost),
                        currencyId = COALESCE(@currencyId, currencyId),
                        exchangeRate = COALESCE(@exchangeRate, exchangeRate),
                        specificAttribute = COALESCE(@specificAttribute, specificAttribute),
                        manufacturerId = COALESCE(@manufacturerId, manufacturerId),
                        labelId = COALESCE(@labelId, labelId) -- Nuevo campo
                    WHERE 
                        id = @productId;

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
            ROLLBACK TRANSACTION [update_tbl_product];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_tbl_product]
    @productId int,
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
            SAVE TRANSACTION [delete_tbl_product];
            DECLARE @errors varchar(max);

            IF NOT EXISTS(SELECT id
    FROM tbl_product
    WHERE id = @productId)
                SET @errors = CONCAT(@errors, 'Producto no encontrado: ', @productId, CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
        UPDATE
                        tbl_product
                    SET
                        status = 0
                    WHERE  
                        id = @productId
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
            ROLLBACK TRANSACTION [delete_tbl_product];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO