--create
CREATE OR ALTER PROCEDURE [dbo].[create_cat_product]
    @name varchar(100),
    @units_name varchar(50),
    @is_set bit,
    @statusId int,
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
            save transaction [create_cat_product];
            declare @errores varchar(max);
            declare @id table(id int);

            IF EXISTS(select id from cat_product where name = @name)
                set @errores = concat(@errores, 'Catalogo de producto ya registrado: ', @name, char(13), char(10));

            IF NOT EXISTS(select id from cat_status where id = @statusId)
                set @errores = concat(@errores, 'Estatus no encontrado: ', @statusId, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    INSERT INTO 
                        cat_product(date_created, date_modified, name, units_name, is_set, statusId)
                    output inserted.id into @id
                    VALUES 
                        (GETDATE(), GETDATE(), @name, @units_name, @is_set, @statusId)
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
            rollback transaction [create_cat_product];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[update_cat_product]
    @productId int,
    @name varchar(100),
    @units_name varchar(50),
    @is_set bit,
    @statusId int,
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
            save transaction [update_cat_product];
            declare @errores varchar(max);
            declare @currentName varchar(100);
            SELECT @currentName = name FROM cat_product WHERE id = @productId

            IF NOT EXISTS(select id from cat_product where id = @productId)
                set @errores = concat(@errores, 'Catalogo de producto no encontrado: ', @name, char(13), char(10));

            IF (@statusId IS NOT NULL) AND NOT EXISTS(select id from cat_status where id = @statusId)
                set @errores = concat(@errores, 'Estatus no encontrado: ', @statusId, char(13), char(10));

            ELSE IF (@currentName = @name)
                set @errores = concat(@errores, 'El nombre no puede ser el mismo: ', @name, char(13), char(10));

            ELSE IF (@currentName <> @name) AND EXISTS(select name from cat_product where name = @name)
                set @errores = concat(@errores, 'Catalogo de producto ya registrado: ', @name, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    UPDATE 
                        cat_product
                    SET
                        date_modified = GETDATE(),
                        name = case when @name is null then name else @name end,
                        units_name = case when @units_name is null then units_name else @units_name end,
                        is_set = case when @is_set is null then is_set else @is_set end,
                        statusId = case when @statusId is null then statusId else @statusId end
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
            rollback transaction [update_cat_product];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_cat_product]
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
            save transaction [delete_cat_product];
            declare @errores varchar(max);

            IF NOT EXISTS(select id from cat_product where id = @productId)
                set @errores = concat(@errores, 'Catalogo de producto no encontrado: ', @productId, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    DELETE FROM
                        cat_product
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
            rollback transaction [delete_cat_product];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO