--create
CREATE OR ALTER PROCEDURE [dbo].[create_cat_currency]
    @currencyName varchar(100),
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
            save transaction [create_cat_currency];
            declare @errores varchar(max);
            declare @id table(id int);

            IF EXISTS(select id from cat_currency where name = @currencyName)
                set @errores = concat(@errores, 'Tipo de cambio ya registrado: ', @currencyName, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    INSERT INTO 
                        cat_currency(date_created, date_modified, name)
                    output inserted.id into @id
                    VALUES 
                        (GETDATE(), GETDATE(), @currencyName)
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
            rollback transaction [create_cat_currency];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END

--update
CREATE OR ALTER PROCEDURE [dbo].[update_cat_currency]
    @currencyId int,
    @currencyName varchar(100),
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
            save transaction [update_cat_currency];
            declare @errores varchar(max);
            declare @currentName varchar(100);
            SELECT @currentName = name FROM cat_currency WHERE id = @currencyId

            IF NOT EXISTS(select id from cat_currency where id = @currencyId)
                set @errores = concat(@errores, 'Tipo de cambio no encontrado: ', @currencyName, char(13), char(10));

            ELSE IF (@currentName = @currencyName)
                set @errores = concat(@errores, 'El nombre no puede ser el mismo: ', @currencyName, char(13), char(10));

            ELSE IF (@currentName <> @currencyName) AND EXISTS(select name from cat_currency where name = @currencyName)
                set @errores = concat(@errores, 'Tipo de cambio ya registrado: ', @currencyName, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    UPDATE 
                        cat_currency
                    SET
                        name = @currencyName,
                        date_modified = GETDATE()
                    WHERE 
                        id = @currencyId
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
            rollback transaction [update_cat_currency];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_cat_currency]
    @currencyId int,
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
            save transaction [delete_cat_currency];
            declare @errores varchar(max);

            IF NOT EXISTS(select id from cat_currency where id = @currencyId)
                set @errores = concat(@errores, 'Tipo de cambio no encontrado: ', @currencyId, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    DELETE FROM
                        cat_currency
                    WHERE  
                        id = @currencyId
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
            rollback transaction [delete_cat_currency];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END