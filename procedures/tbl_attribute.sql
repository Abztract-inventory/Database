--create
CREATE OR ALTER PROCEDURE [dbo].[create_tbl_attribute]
    @key_name varchar(100),
    @type varchar(20),
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
            save transaction [create_tbl_attribute];
            declare @errores varchar(max);
            declare @id table(id int);

            IF EXISTS(select id from tbl_attribute where key_name = @key_name AND type = @type)
                set @errores = concat(@errores, 'Atributo ya registrado: ', char(13), char(10));

            IF(@errores is null)
                BEGIN
                    INSERT INTO 
                        tbl_attribute(date_created, date_modified, key_name, type)
                    output inserted.id into @id
                    VALUES 
                        (GETDATE(), GETDATE(), @key_name, @type)
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
            rollback transaction [create_tbl_attribute];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO

--update
CREATE OR ALTER PROCEDURE [dbo].[update_tbl_attribute]
    @attributeId int,
    @key_name varchar(100),
    @type varchar(20),
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
            save transaction [update_tbl_attribute];
            declare @errores varchar(max);

            IF NOT EXISTS(select id from tbl_attribute where id = @attributeId)
                set @errores = concat(@errores, 'Atributo no encontrado, id: ', @attributeId, char(13), char(10));

            ELSE IF EXISTS(select id from tbl_attribute where key_name = @key_name AND type = @type)
                set @errores = concat(@errores, 'Atributo ya registrado, key_name: ', @key_name, ', type: ', @type, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    UPDATE 
                        tbl_attribute
                    SET
                        key_name = @key_name,
                        type = @type,
                        date_modified = GETDATE()
                    WHERE 
                        id = @attributeId
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
            rollback transaction [update_tbl_attribute];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO

--delete
CREATE OR ALTER PROCEDURE [dbo].[delete_tbl_attribute]
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
            save transaction [delete_tbl_attribute];
            declare @errores varchar(max);

            IF NOT EXISTS(select id from tbl_attribute where id = @attributeId)
                set @errores = concat(@errores, 'Atributo no encontrado: ', @attributeId, char(13), char(10));

            IF(@errores is null)
                BEGIN
                    DELETE FROM
                        tbl_attribute
                    WHERE  
                        id = @attributeId
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
            rollback transaction [delete_tbl_attribute];
        SELECT 0 affects_rows, @message error, null id;
    END CATCH
END
GO