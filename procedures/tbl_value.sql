--create
CREATE OR ALTER PROCEDURE [dbo].[create_tbl_value]
    @value varchar(max),
    @productId int, --tbl_product
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
            save transaction [create_tbl_value];
            declare @errores varchar(max);
            declare @id table(id int);

            IF EXISTS(select id from tbl_value where value = @value AND productId = @productId AND attributeId = @attributeId)
                set @errores = concat(@errores, 'Valor ya registrado: ', char(13), char(10));

            IF (@productId IS NOT NULL) AND NOT EXISTS(select id from tbl_product where id = @productId)
                set @errores = concat(@errores, 'Prodcuto no encontrado: ', char(13), char(10));
            
            IF (@attributeId IS NOT NULL) AND NOT EXISTS(select id from tbl_attribute where id = @attributeId)
                set @errores = concat(@errores, 'Atributo no encontrado: ', char(13), char(10));

            IF(@errores is null)
                BEGIN
                    INSERT INTO 
                        tbl_value(date_created, date_modified, value, productId, attributeId)
                    output inserted.id into @id
                    VALUES 
                        (GETDATE(), GETDATE(), @value, @productId, @attributeId)
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
            rollback transaction [create_tbl_value];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[update_tbl_value]
    @valueId int,
    @value varchar(max),
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
            save transaction [update_tbl_value];
            declare @errores varchar(max);

            IF NOT EXISTS(select id from tbl_value where id = @valueId)
                set @errores = concat(@errores, 'Atributo no encontrado, id: ', @valueId, char(13), char(10));

            IF (@productId IS NOT NULL) AND NOT EXISTS(select id from tbl_product where id = @productId)
                set @errores = concat(@errores, 'Prodcuto no encontrado: ', char(13), char(10));
            
            IF (@attributeId IS NOT NULL) AND NOT EXISTS(select id from tbl_attribute where id = @attributeId)
                set @errores = concat(@errores, 'Atributo no encontrado: ', char(13), char(10));

            ELSE IF EXISTS(select id from tbl_value where value = @value AND productId = @productId AND attributeId = @attributeId)
                set @errores = concat(@errores, 'Valor ya registrado: ', char(13), char(10));

            IF(@errores is null)
                BEGIN
                    UPDATE 
                        tbl_value
                    SET
                        value = @value,
                        productId = @productId,
                        attributeId = @attributeId,
                        date_modified = GETDATE()
                    WHERE 
                        id = @valueId
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
            rollback transaction [update_tbl_value];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_tbl_value]
    @valueId int,
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
            save transaction [delete_tbl_value];
            declare @errores varchar(max);

            IF NOT EXISTS(select id from tbl_value where id = @valueId)
                set @errores = concat(@errores, 'Valor no encontrado: ', @valueId, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    DELETE FROM
                        tbl_value
                    WHERE  
                        id = @valueId
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
            rollback transaction [delete_tbl_value];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO