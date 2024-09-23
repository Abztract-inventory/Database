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

--update
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
    set nocount on;
    declare @trancount int;
    set @trancount = @@trancount;
BEGIN
    BEGIN TRY
        if @trancount = 0
            begin transaction
        else
            save transaction [update_tbl_product];
            declare @errores varchar(max);

            IF NOT EXISTS(select id from tbl_product where id = @productId)
                set @errores = concat(@errores, 'Producto no encontrado, id: ', @productId, char(13), char(10));

            IF (@catProductId IS NOT NULL) AND NOT EXISTS(select id from cat_product where id = @catProductId)
                set @errores = concat(@errores, 'Catalogo de producto no encontrado: ', char(13), char(10));

            IF (@materialId IS NOT NULL) AND NOT EXISTS(select id from cat_material where id = @materialId)
                set @errores = concat(@errores, 'Material no encontrado: ', char(13), char(10));

            IF (@companyId IS NOT NULL) AND NOT EXISTS(select id from cat_company where id = @companyId)
                set @errores = concat(@errores, 'Empresa no encontrada: ', char(13), char(10));

            IF (@currencyId IS NOT NULL) AND NOT EXISTS(select id from cat_currency where id = @currencyId)
                set @errores = concat(@errores, 'Tipo de cambio no encontrado: ', char(13), char(10));

            IF (@manufacturerId IS NOT NULL) AND NOT EXISTS(select id from cat_manufacturer where id = @manufacturerId)
                set @errores = concat(@errores, 'Fabricante no encontrado: ', char(13), char(10));

            IF(@errores is null)
                BEGIN
                    UPDATE 
                        tbl_product
                    SET
                        date_modified = GETDATE(), 
                        productId = @catProductId, 
                        document_number = @document_number, 
                        supplier_number = @supplier_number, 
                        materialId = @materialId, 
                        quantity = @quantity, 
                        unit_value = @unit_value, 
                        grammage = @grammage, 
                        width = @width, 
                        lenght = @lenght, 
                        height = @height, 
                        is_printed = @is_printed, 
                        is_waxed = @is_waxed, 
                        companyId = @companyId, 
                        cost = @cost, 
                        currencyId = @currencyId, 
                        exchange_rate = @exchange_rate, 
                        specific_attribute = @specific_attribute, 
                        manufacturerId = @manufacturerId
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
            rollback transaction [update_tbl_product];
        SELECT 0 affects_rows, @message error, null id;
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