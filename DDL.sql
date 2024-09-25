CREATE DATABASE abztract;
GO 

USE abztract;
GO

-- CREATE TABLE gen(
--     id int identity (1,1) PRIMARY KEY,
--     date_created datetime,
--     date_modified datetime,
-- );

CREATE TABLE cat_status(
    id int identity (1,1) PRIMARY KEY,
    date_created datetime,
    date_modified datetime,
    name varchar(100)
);

CREATE TABLE cat_material(
    id int identity (1,1) PRIMARY KEY,
    date_created datetime,
    date_modified datetime,
    name varchar(100)
);

CREATE TABLE cat_company(
    id int identity (1,1) PRIMARY KEY,
    date_created datetime,
    date_modified datetime,
    name varchar(100)
);

CREATE TABLE cat_currency(
    id int identity (1,1) PRIMARY KEY,
    date_created datetime,
    date_modified datetime,
    name varchar(100)
);

CREATE TABLE cat_manufacturer(
    id int identity (1,1) PRIMARY KEY,
    date_created datetime,
    date_modified datetime,
    name varchar(100)
);

CREATE TABLE cat_product(
    id int identity (1,1) PRIMARY KEY,
    date_created datetime,
    date_modified datetime,
    status bit,
    name varchar(100),
    units_name varchar(50),
    is_set bit,
    statusId int NOT NULL REFERENCES cat_status
);

CREATE INDEX cat_product_statusId ON cat_product(statusId);

CREATE TABLE tbl_attribute(
    id int identity (1,1) PRIMARY KEY,
    date_created datetime,
    date_modified datetime,
    key_name varchar(100),
    type varchar(20)
);

CREATE TABLE rel_product_attribute(
    id int identity (1,1) PRIMARY KEY,
    date_created datetime,
    date_modified datetime,
    productId int NOT NULL REFERENCES cat_product,
    attributeId int NOT NULL REFERENCES tbl_attribute
);

CREATE INDEX rel_product_attribute_productId ON rel_product_attribute(productId);
CREATE INDEX rel_product_attribute_attributeId ON rel_product_attribute(attributeId);

CREATE TABLE tbl_product(
    id int identity (1,1) PRIMARY KEY,
    date_created datetime,
    date_modified datetime,
    status bit,
    productId int NOT NULL REFERENCES cat_product,
    document_number varchar(30),
    supplier_number varchar(30),
    materialId int NOT NULL REFERENCES cat_material,
    quantity float,
    unit_value float,
    grammage float,
    width float,
    lenght float,
    height float,
    is_printed bit,
    is_waxed bit,
    companyId int NOT NULL REFERENCES cat_company,
    cost float,
    currencyId int NOT NULL REFERENCES cat_currency,
    exchange_rate float,
    specific_attribute varchar(MAX),
    manufacturerId int NOT NULL REFERENCES cat_manufacturer
);

CREATE INDEX tbl_product_productId ON tbl_product(productId);
CREATE INDEX tbl_product_materialId ON tbl_product(materialId);
CREATE INDEX tbl_product_companyId ON tbl_product(companyId);
CREATE INDEX tbl_product_currencyId ON tbl_product(currencyId);
CREATE INDEX tbl_product_manufacturerId ON tbl_product(manufacturerId);

CREATE TABLE tbl_value(
    id int identity (1,1) PRIMARY KEY,
    date_created datetime,
    date_modified datetime,
    value varchar(max),
    attributeId int NOT NULL REFERENCES tbl_attribute,
    productId int NOT NULL REFERENCES tbl_product
);

CREATE INDEX tbl_value_attributeId ON tbl_value(attributeId);
CREATE INDEX tbl_value_productId ON tbl_value(productId);