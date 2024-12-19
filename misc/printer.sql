-- Ejemplo para crear una impresora
DECLARE @NuevaImpresoraId int;

EXEC [dbo].[create_tbl_printers]
    @ip = '192.168.10.50',
    @model = 'QL-810W',
    @locationId = 1,
    @protocol = 'BrotherQLRaster',
    @alias = 'Oficina Principal',
    @idOut = @NuevaImpresoraId OUTPUT;

SELECT @NuevaImpresoraId AS IdImpresoraCreada;