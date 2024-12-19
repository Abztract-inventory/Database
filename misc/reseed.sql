-- Borrar todos los registros y reiniciar el índice de rel_location_label
DELETE FROM rel_location_label;
DBCC CHECKIDENT ('rel_location_label', RESEED, 0);

-- Borrar todos los registros y reiniciar el índice de his_product_movement
DELETE FROM his_product_movement;
DBCC CHECKIDENT ('his_product_movement', RESEED, 0);

-- Borrar todos los registros y reiniciar el índice de tbl_production_batch
DELETE FROM tbl_production_batch;
DBCC CHECKIDENT ('tbl_production_batch', RESEED, 0);

-- Borrar todos los registros y reiniciar el índice de tbl_product
DELETE FROM tbl_product;
DBCC CHECKIDENT ('tbl_product', RESEED, 0);

-- Borrar todos los registros y reiniciar el índice de tbl_label
DELETE FROM tbl_label;
DBCC CHECKIDENT ('tbl_label', RESEED, 0);

-- Borrar todos los registros y reiniciar el índice de tbl_printers
DELETE FROM tbl_printers;
DBCC CHECKIDENT ('tbl_printers', RESEED, 0);