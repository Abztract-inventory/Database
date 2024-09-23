--create
CREATE OR ALTER PROCEDURE [dbo].[create_cat_status]
    @statusName varchar(100),
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
            save transaction [create_cat_status];
            declare @errores varchar(max);
            declare @id table(id int);

            IF EXISTS(select id from cat_status where name = @statusName)
                set @errores = concat(@errores, 'Estatus ya registrado: ', @statusName, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    INSERT INTO 
                        cat_status(date_created, date_modified, name)
                    output inserted.id into @id
                    VALUES 
                        (GETDATE(), GETDATE(), @statusName)
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
            rollback transaction [create_cat_status];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[update_cat_status]
    @statusId int,
    @statusName varchar(100),
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
            save transaction [update_cat_status];
            declare @errores varchar(max);
            declare @currentName varchar(100);
            SELECT @currentName = name FROM cat_status WHERE id = @statusId

            IF NOT EXISTS(select id from cat_status where id = @statusId)
                set @errores = concat(@errores, 'Estatus no encontrado: ', @statusName, char(13), char(10));

            ELSE IF (@currentName = @statusName)
                set @errores = concat(@errores, 'El nombre no puede ser el mismo: ', @statusName, char(13), char(10));

            ELSE IF (@currentName <> @statusName) AND EXISTS(select name from cat_status where name = @statusName)
                set @errores = concat(@errores, 'Estatus ya registrado: ', @statusName, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    UPDATE 
                        cat_status
                    SET
                        name = @statusName,
                        date_modified = GETDATE()
                    WHERE 
                        id = @statusId
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
            rollback transaction [update_cat_status];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_cat_status]
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
            save transaction [delete_cat_status];
            declare @errores varchar(max);

            IF NOT EXISTS(select id from cat_status where id = @statusId)
                set @errores = concat(@errores, 'Estatus no encontrado: ', @statusId, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    DELETE FROM
                        cat_status
                    WHERE  
                        id = @statusId
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
            rollback transaction [delete_cat_status];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO