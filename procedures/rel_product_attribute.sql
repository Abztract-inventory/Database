--create
CREATE OR ALTER PROCEDURE [dbo].[create_rel_product_attribute]
    @productId int, --cat_product
    @attributeId int,
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
            save transaction [create_rel_product_attribute];
            declare @errores varchar(max);
            declare @id table(id int);

            IF EXISTS(select id from rel_product_attribute where productId = @productId AND attributeId = @attributeId)
                set @errores = concat(@errores, 'Relacion ya registrada: ', char(13), char(10));

            IF (@productId IS NOT NULL) AND NOT EXISTS(select id from cat_product where id = @productId)
                set @errores = concat(@errores, 'Catalogo de prodcuto no encontrado: ', char(13), char(10));
            
            IF (@attributeId IS NOT NULL) AND NOT EXISTS(select id from tbl_attribute where id = @attributeId)
                set @errores = concat(@errores, 'Atributo no encontrado: ', char(13), char(10));

            IF(@errores is null)
                BEGIN
                    INSERT INTO 
                        rel_product_attribute(date_created, date_modified, productId, attributeId)
                    output inserted.id into @id
                    VALUES 
                        (GETDATE(), GETDATE(), @productId, @attributeId)
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
            rollback transaction [create_rel_product_attribute];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_rel_product_attribute]
    @productId int,
    @attributeId int,
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
            save transaction [delete_rel_product_attribute];
            declare @errores varchar(max);

            IF NOT EXISTS(select id from rel_product_attribute where productId = @productId AND attributeId = @attributeId)
                set @errores = concat(@errores, 'Relacion no encontrada: ', char(13), char(10));

            IF(@errores is null)
                BEGIN
                    DELETE FROM
                        rel_product_attribute
                    WHERE  
                        productId = @productId AND attributeId = @attributeId
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
            rollback transaction [delete_rel_product_attribute];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO