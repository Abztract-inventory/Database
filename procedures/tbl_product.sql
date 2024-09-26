--tbl_product.sql
--create
CREATE OR ALTER PROCEDURE [dbo].[createTblProduct]
    @catProductId int, --cat_product
    @documentNumber varchar(30),
    @supplierNumber varchar(30),
    @materialId int,
    @quantity float,
    @unitValue float,
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
            SAVE TRANSACTION [createTblProduct];
            DECLARE @errors varchar(max);
            DECLARE @id TABLE(id int);

            IF NOT EXISTS(SELECT id FROM cat_product WHERE id = @catProductId)
                SET @errors = CONCAT(@errors, 'Catálogo de producto no encontrado.', CHAR(13), CHAR(10));

            IF NOT EXISTS(SELECT id FROM cat_material WHERE id = @materialId)
                SET @errors = CONCAT(@errors, 'Material no encontrado.', CHAR(13), CHAR(10));

            IF NOT EXISTS(SELECT id FROM cat_company WHERE id = @companyId)
                SET @errors = CONCAT(@errors, 'Empresa no encontrada.', CHAR(13), CHAR(10));

            IF NOT EXISTS(SELECT id FROM cat_currency WHERE id = @currencyId)
                SET @errors = CONCAT(@errors, 'Tipo de cambio no encontrado.', CHAR(13), CHAR(10));

            IF NOT EXISTS(SELECT id FROM cat_manufacturer WHERE id = @manufacturerId)
                SET @errors = CONCAT(@errors, 'Fabricante no encontrado.', CHAR(13), CHAR(10));

            IF(@errors IS NULL)
                BEGIN
                    INSERT INTO 
                        tbl_product(
                            dateCreated, 
                            dateModified, 
                            status, 
                            productId, 
                            documentNumber, 
                            supplierNumber, 
                            materialId, 
                            quantity, 
                            unitValue, 
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
                            manufacturerId
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
                            @quantity, 
                            @unitValue, 
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
                            @manufacturerId    
                        )
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
            ROLLBACK TRANSACTION [createTblProduct];
        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[updateTblProduct]
    @productId int,
    @catProductId int, --cat_product
    @documentNumber varchar(30),
    @supplierNumber varchar(30),
    @materialId int,
    @quantity float,
    @unitValue float,
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
            SAVE TRANSACTION [updateTblProduct];

            DECLARE @errors varchar(max);

            IF NOT EXISTS(SELECT id FROM tbl_product WHERE id = @productId)
                SET @errors = CONCAT(@errors, 'Producto no encontrado, id: ', @productId, CHAR(13), CHAR(10));

            IF (@catProductId IS NOT NULL) AND NOT EXISTS(SELECT id FROM cat_product WHERE id = @catProductId)
                SET @errors = CONCAT(@errors, 'Catálogo de producto no encontrado.', CHAR(13), CHAR(10));

            IF (@materialId IS NOT NULL) AND NOT EXISTS(SELECT id FROM cat_material WHERE id = @materialId)
                SET @errors = CONCAT(@errors, 'Material no encontrado.', CHAR(13), CHAR(10));

            IF (@companyId IS NOT NULL) AND NOT EXISTS(SELECT id FROM cat_company WHERE id = @companyId)
                SET @errors = CONCAT(@errors, 'Empresa no encontrada.', CHAR(13), CHAR(10));

            IF (@currencyId IS NOT NULL) AND NOT EXISTS(SELECT id FROM cat_currency WHERE id = @currencyId)
                SET @errors = CONCAT(@errors, 'Tipo de cambio no encontrado.', CHAR(13), CHAR(10));

            IF (@manufacturerId IS NOT NULL) AND NOT EXISTS(SELECT id FROM cat_manufacturer WHERE id = @manufacturerId)
                SET @errors = CONCAT(@errors, 'Fabricante no encontrado.', CHAR(13), CHAR(10));

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
                        quantity = COALESCE(@quantity, quantity),
                        unitValue = COALESCE(@unitValue, unitValue),
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
                        manufacturerId = COALESCE(@manufacturerId, manufacturerId)
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
            ROLLBACK TRANSACTION [updateTblProduct];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[deleteTblProduct]
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
            SAVE TRANSACTION [deleteTblProduct];
            DECLARE @errors varchar(max);

            IF NOT EXISTS(SELECT id FROM tbl_product WHERE id = @productId)
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
            ROLLBACK TRANSACTION [deleteTblProduct];

        SELECT 0 AS affects_rows, @message AS error, NULL AS id;
    END CATCH
END
GO