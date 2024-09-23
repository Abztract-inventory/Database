--create
CREATE OR ALTER PROCEDURE [dbo].[create_cat_manufacturer]
    @manufacturerName varchar(100),
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
            save transaction [create_cat_manufacturer];
            declare @errores varchar(max);
            declare @id table(id int);

            IF EXISTS(select id from cat_manufacturer where name = @manufacturerName)
                set @errores = concat(@errores, 'Fabricante ya registrado: ', @manufacturerName, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    INSERT INTO 
                        cat_manufacturer(date_created, date_modified, name)
                    output inserted.id into @id
                    VALUES 
                        (GETDATE(), GETDATE(), @manufacturerName)
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
            rollback transaction [create_cat_manufacturer];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[update_cat_manufacturer]
    @manufacturerId int,
    @manufacturerName varchar(100),
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
            save transaction [update_cat_manufacturer];
            declare @errores varchar(max);
            declare @currentName varchar(100);
            SELECT @currentName = name FROM cat_manufacturer WHERE id = @manufacturerId

            IF NOT EXISTS(select id from cat_manufacturer where id = @manufacturerId)
                set @errores = concat(@errores, 'Fabricante no encontrado: ', @manufacturerName, char(13), char(10));

            ELSE IF (@currentName = @manufacturerName)
                set @errores = concat(@errores, 'El nombre no puede ser el mismo: ', @manufacturerName, char(13), char(10));

            ELSE IF (@currentName <> @manufacturerName) AND EXISTS(select name from cat_manufacturer where name = @manufacturerName)
                set @errores = concat(@errores, 'Fabricante ya registrado: ', @manufacturerName, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    UPDATE 
                        cat_manufacturer
                    SET
                        name = @manufacturerName,
                        date_modified = GETDATE()
                    WHERE 
                        id = @manufacturerId
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
            rollback transaction [update_cat_manufacturer];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_cat_manufacturer]
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
            save transaction [delete_cat_manufacturer];
            declare @errores varchar(max);

            IF NOT EXISTS(select id from cat_manufacturer where id = @manufacturerId)
                set @errores = concat(@errores, 'Fabricante no encontrado: ', @manufacturerId, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    DELETE FROM
                        cat_manufacturer
                    WHERE  
                        id = @manufacturerId
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
            rollback transaction [delete_cat_manufacturer];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO