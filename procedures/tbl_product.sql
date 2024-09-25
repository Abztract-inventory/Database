--create
CREATE OR ALTER PROCEDURE [dbo].[create_tbl_product]
    @catProductId int, --cat_product
    @document_number varchar(30),
    @supplier_number varchar(30),
    @materialId int,
    @quantity float,
    @unit_value float,
    @grammage float,
    @width float,
    @lenght float,
    @height float,
    @is_printed bit,
    @is_waxed bit,
    @companyId int,
    @cost float,
    @currencyId int,
    @exchange_rate float,
    @specific_attribute varchar(MAX),
	@manufacturerId int,
    @idOut int = null output
AS
    set nocount on;
    declare @trancount int;
    set @trancount = @@trancount;
BEGIN
    BEGIN TRY
        if @trancount = 0
            begin transaction
        else
            save transaction [create_tbl_product];
            declare @errores varchar(max);
            declare @id table(id int);

            IF NOT EXISTS(select id from cat_product where id = @catProductId)
                set @errores = concat(@errores, 'Catalogo de producto no encontrado: ', char(13), char(10));

            IF NOT EXISTS(select id from cat_material where id = @materialId)
                set @errores = concat(@errores, 'Material no encontrado: ', char(13), char(10));

            IF NOT EXISTS(select id from cat_company where id = @companyId)
                set @errores = concat(@errores, 'Empresa no encontrada: ', char(13), char(10));

            IF NOT EXISTS(select id from cat_currency where id = @currencyId)
                set @errores = concat(@errores, 'Tipo de cambio no encontrado: ', char(13), char(10));

            IF NOT EXISTS(select id from cat_manufacturer where id = @manufacturerId)
                set @errores = concat(@errores, 'Fabricante no encontrado: ', char(13), char(10));

            IF(@errores is null)
                BEGIN
                    INSERT INTO 
                        tbl_product(
                            date_created, 
                            date_modified, 
                            status, 
                            productId, 
                            document_number, 
                            supplier_number, 
                            materialId, 
                            quantity, 
                            unit_value, 
                            grammage, 
                            width, 
                            lenght, 
                            height, 
                            is_printed, 
                            is_waxed, 
                            companyId, 
                            cost, 
                            currencyId, 
                            exchange_rate, 
                            specific_attribute, 
                            manufacturerId
                            )
                    output inserted.id into @id
                    VALUES 
                        (
                            GETDATE(), 
                            GETDATE(), 
                            1, 
                            @catProductId, 
                            @document_number, 
                            @supplier_number, 
                            @materialId, 
                            @quantity, 
                            @unit_value, 
                            @grammage, 
                            @width, 
                            @lenght, 
                            @height, 
                            @is_printed, 
                            @is_waxed, 
                            @companyId, 
                            @cost, 
                            @currencyId, 
                            @exchange_rate, 
                            @specific_attribute, 
                            @manufacturerId    
                        )
                    select TOP 1 @idOut = id from @id
                    SELECT 1 affects_rows, null error, @idOut id;
                END
            ELSE
                BEGIN
                    SELECT 0 affects_rows, @errores error, @idOut id;
                END
        lbexit:
            if @trancount = 0
                commit;
    END TRY
    BEGIN CATCH
        declare @error int, @message varchar(4000), @xstate int;
        select @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();
        if @xstate = -1
            rollback;
        if @xstate = 1
            rollback
        if @xstate = 1 and @trancount > 0
            rollback transaction [create_tbl_product];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [dbo].[update_tbl_product]
    @productId int,
    @catProductId int, --cat_product
    @document_number varchar(30),
    @supplier_number varchar(30),
    @materialId int,
    @quantity float,
    @unit_value float,
    @grammage float,
    @width float,
    @lenght float,
    @height float,
    @is_printed bit,
    @is_waxed bit,
    @companyId int,
    @cost float,
    @currencyId int,
    @exchange_rate float,
    @specific_attribute varchar(MAX),
    @manufacturerId int,
    @idOut int = null output
AS
    SET NOCOUNT ON;
    DECLARE @trancount int;
    SET @trancount = @@trancount;
BEGIN
    BEGIN TRY
        IF @trancount = 0
            BEGIN TRANSACTION
        ELSE
            SAVE TRANSACTION [update_tbl_product];

        DECLARE @errores varchar(max);

        IF NOT EXISTS(SELECT id FROM tbl_product WHERE id = @productId)
            SET @errores = CONCAT(@errores, 'Producto no encontrado, id: ', @productId, CHAR(13), CHAR(10));

        IF (@catProductId IS NOT NULL) AND NOT EXISTS(SELECT id FROM cat_product WHERE id = @catProductId)
            SET @errores = CONCAT(@errores, 'Catalogo de producto no encontrado: ', CHAR(13), CHAR(10));

        IF (@materialId IS NOT NULL) AND NOT EXISTS(SELECT id FROM cat_material WHERE id = @materialId)
            SET @errores = CONCAT(@errores, 'Material no encontrado: ', CHAR(13), CHAR(10));

        IF (@companyId IS NOT NULL) AND NOT EXISTS(SELECT id FROM cat_company WHERE id = @companyId)
            SET @errores = CONCAT(@errores, 'Empresa no encontrada: ', CHAR(13), CHAR(10));

        IF (@currencyId IS NOT NULL) AND NOT EXISTS(SELECT id FROM cat_currency WHERE id = @currencyId)
            SET @errores = CONCAT(@errores, 'Tipo de cambio no encontrado: ', CHAR(13), CHAR(10));

        IF (@manufacturerId IS NOT NULL) AND NOT EXISTS(SELECT id FROM cat_manufacturer WHERE id = @manufacturerId)
            SET @errores = CONCAT(@errores, 'Fabricante no encontrado: ', CHAR(13), CHAR(10));

        IF(@errores IS NULL)
        BEGIN
            UPDATE 
                tbl_product
            SET
                date_modified = GETDATE(),
                productId = CASE WHEN @catProductId IS NULL THEN productId ELSE @catProductId END,
                document_number = CASE WHEN @document_number IS NULL THEN document_number ELSE @document_number END,
                supplier_number = CASE WHEN @supplier_number IS NULL THEN supplier_number ELSE @supplier_number END,
                materialId = CASE WHEN @materialId IS NULL THEN materialId ELSE @materialId END,
                quantity = CASE WHEN @quantity IS NULL THEN quantity ELSE @quantity END,
                unit_value = CASE WHEN @unit_value IS NULL THEN unit_value ELSE @unit_value END,
                grammage = CASE WHEN @grammage IS NULL THEN grammage ELSE @grammage END,
                width = CASE WHEN @width IS NULL THEN width ELSE @width END,
                lenght = CASE WHEN @lenght IS NULL THEN lenght ELSE @lenght END,
                height = CASE WHEN @height IS NULL THEN height ELSE @height END,
                is_printed = CASE WHEN @is_printed IS NULL THEN is_printed ELSE @is_printed END,
                is_waxed = CASE WHEN @is_waxed IS NULL THEN is_waxed ELSE @is_waxed END,
                companyId = CASE WHEN @companyId IS NULL THEN companyId ELSE @companyId END,
                cost = CASE WHEN @cost IS NULL THEN cost ELSE @cost END,
                currencyId = CASE WHEN @currencyId IS NULL THEN currencyId ELSE @currencyId END,
                exchange_rate = CASE WHEN @exchange_rate IS NULL THEN exchange_rate ELSE @exchange_rate END,
                specific_attribute = CASE WHEN @specific_attribute IS NULL THEN specific_attribute ELSE @specific_attribute END,
                manufacturerId = CASE WHEN @manufacturerId IS NULL THEN manufacturerId ELSE @manufacturerId END
            WHERE 
                id = @productId;

            SELECT 1 affects_rows, NULL error, @idOut id;
        END
        ELSE
        BEGIN
            SELECT 0 affects_rows, @errores error, @idOut id;
        END

        lbexit:
            IF @trancount = 0
                COMMIT;
    END TRY
    BEGIN CATCH
        DECLARE @error int, @message varchar(4000), @xstate int;
        SELECT @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();

        IF @xstate = -1
            ROLLBACK;

        IF @xstate = 1
            ROLLBACK;

        IF @xstate = 1 AND @trancount > 0
            ROLLBACK TRANSACTION [update_tbl_product];

        SELECT 0 affects_rows, @message error, NULL id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_tbl_product]
    @productId int,
    @idOut int = null output
AS
    set nocount on;
    declare @trancount int;
    set @trancount = @@trancount;
BEGIN
    BEGIN TRY
        if @trancount = 0
            begin transaction
        else
            save transaction [delete_tbl_product];
            declare @errores varchar(max);

            IF NOT EXISTS(select id from tbl_product where id = @productId)
                set @errores = concat(@errores, 'Producto no encontrado: ', @productId, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    UPDATE
                        tbl_product
                    SET
                        status = 0
                    WHERE  
                        id = @productId
                    SELECT 1 affects_rows, null error, @idOut id;
                END
            ELSE
                BEGIN
                    SELECT 0 affects_rows, @errores error, @idOut id;
                END
        lbexit:
            if @trancount = 0
                commit;
    END TRY
    BEGIN CATCH
        declare @error int, @message varchar(4000), @xstate int;
        select @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();
        if @xstate = -1
            rollback;
        if @xstate = 1
            rollback
        if @xstate = 1 and @trancount > 0
            rollback transaction [delete_tbl_product];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO