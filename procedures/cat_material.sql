--create
CREATE OR ALTER PROCEDURE [dbo].[create_cat_material]
    @materialName varchar(100),
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
            save transaction [create_cat_material];
            declare @errores varchar(max);
            declare @id table(id int);

            IF EXISTS(select id from cat_material where name = @materialName)
                set @errores = concat(@errores, 'Material ya registrado: ', @materialName, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    INSERT INTO 
                        cat_material(date_created, date_modified, name)
                    output inserted.id into @id
                    VALUES 
                        (GETDATE(), GETDATE(), @materialName)
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
            rollback transaction [create_cat_material];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[update_cat_material]
    @materialId int,
    @materialName varchar(100),
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
            save transaction [update_cat_material];
            declare @errores varchar(max);
            declare @currentName varchar(100);
            SELECT @currentName = name FROM cat_material WHERE id = @materialId

            IF NOT EXISTS(select id from cat_material where id = @materialId)
                set @errores = concat(@errores, 'Material no encontrado: ', @materialName, char(13), char(10));

            ELSE IF (@currentName = @materialName)
                set @errores = concat(@errores, 'El nombre no puede ser el mismo: ', @materialName, char(13), char(10));

            ELSE IF (@currentName <> @materialName) AND EXISTS(select name from cat_material where name = @materialName)
                set @errores = concat(@errores, 'Material ya registrado: ', @materialName, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    UPDATE 
                        cat_material
                    SET
                        name = @materialName,
                        date_modified = GETDATE()
                    WHERE 
                        id = @materialId
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
            rollback transaction [update_cat_material];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_cat_material]
    @materialId int,
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
            save transaction [delete_cat_material];
            declare @errores varchar(max);

            IF NOT EXISTS(select id from cat_material where id = @materialId)
                set @errores = concat(@errores, 'Material no encontrado: ', @materialId, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    DELETE FROM
                        cat_material
                    WHERE  
                        id = @materialId
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
            rollback transaction [delete_cat_material];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO