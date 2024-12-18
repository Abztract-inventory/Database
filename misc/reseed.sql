-- Borrar todos los registros y reiniciar el índice de tbl_product
DELETE FROM tbl_product;
DBCC CHECKIDENT ('tbl_product', RESEED, 0);

-- Borrar todos los registros y reiniciar el índice de tbl_label
DELETE FROM tbl_label;
DBCC CHECKIDENT ('tbl_label', RESEED, 0);

-- Borrar todos los registros y reiniciar el índice de tbl_printers
DELETE FROM tbl_printers;
DBCC CHECKIDENT ('tbl_printers', RESEED, 0);