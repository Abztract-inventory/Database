--DDL.sql
CREATE DATABASE abztract;
GO

USE abztract;
GO

-- CREATE TABLE gen(
--     id int identity (1,1) PRIMARY KEY,
--     dateCreated datetime,
--     dateModified datetime,
-- );

CREATE TABLE cat_status
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    name varchar(100)
);

CREATE TABLE cat_material
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    name varchar(100)
);

CREATE TABLE cat_company
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    name varchar(100)
);

CREATE TABLE cat_currency
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    name varchar(100)
);

CREATE TABLE cat_manufacturer
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    name varchar(100)
);

CREATE TABLE cat_product
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    status bit,
    name varchar(100),
    unitsName varchar(50),
    isSet bit,
    --statusId int NOT NULL REFERENCES cat_status
);

CREATE INDEX cat_product_statusId ON cat_product(statusId);

CREATE TABLE tbl_attribute
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    keyName varchar(100),
    type varchar(20)
);

CREATE TABLE rel_product_attribute
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    productId int NOT NULL REFERENCES cat_product,
    attributeId int NOT NULL REFERENCES tbl_attribute
);

CREATE INDEX rel_product_attribute_productId ON rel_product_attribute(productId);
CREATE INDEX rel_product_attribute_attributeId ON rel_product_attribute(attributeId);

CREATE TABLE tbl_label
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    label varchar(50)
);

CREATE INDEX tbl_label_label ON tbl_label(label);

CREATE TABLE tbl_product
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    status bit,
    productId int NOT NULL REFERENCES cat_product,
    documentNumber varchar(30),
    supplierNumber varchar(30),
    materialId int NOT NULL REFERENCES cat_material,
    grammage float,
    width float,
    length float,
    height float,
    isPrinted bit,
    isWaxed bit,
    companyId int NOT NULL REFERENCES cat_company,
    cost float,
    currencyId int NOT NULL REFERENCES cat_currency,
    exchangeRate float,
    specificAttribute varchar(MAX),
    manufacturerId int NOT NULL REFERENCES cat_manufacturer,
    -- labelId int NOT NULL REFERENCES tbl_label
    labelId int REFERENCES tbl_label
);

CREATE INDEX tbl_product_productId ON tbl_product(productId);
CREATE INDEX tbl_product_materialId ON tbl_product(materialId);
CREATE INDEX tbl_product_companyId ON tbl_product(companyId);
CREATE INDEX tbl_product_currencyId ON tbl_product(currencyId);
CREATE INDEX tbl_product_manufacturerId ON tbl_product(manufacturerId);

CREATE TABLE tbl_value
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    value varchar(max),
    attributeId int NOT NULL REFERENCES tbl_attribute,
    productId int NOT NULL REFERENCES tbl_product
);

CREATE INDEX tbl_value_attributeId ON tbl_value(attributeId);
CREATE INDEX tbl_value_productId ON tbl_value(productId);

CREATE TABLE tbl_location
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    principalModified varchar(100),
    nave varchar(100),
    section varchar(100),
    comment varchar(250)
);

CREATE TABLE tbl_printers
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    ip varchar(15) NOT NULL,
    model varchar(20) NOT NULL,
    locationId int NOT NULL REFERENCES tbl_location,
    protocol varchar(20) NOT NULL,
    alias varchar(20)
);

CREATE TABLE cat_machine
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    principalModified varchar(100),
    locationId int NOT NULL REFERENCES tbl_location,
    machine varchar(150)
);

CREATE TABLE tbl_production_batch
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    machineId int NOT NULL REFERENCES cat_machine
);

CREATE TABLE his_product_movement
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    principalModified varchar(100),
    labelId int NOT NULL REFERENCES tbl_label,
    quantity float,
    unitValue float,
    reason varchar(500),
    inFlag bit,
    batchId int NOT NULL REFERENCES tbl_production_batch
);

CREATE TABLE rel_location_label
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    locationId int NOT NULL REFERENCES tbl_location,
    labelId int NOT NULL REFERENCES tbl_label
);

CREATE INDEX rel_location_label_locationId ON rel_location_label(locationId);
CREATE INDEX rel_location_label_labelId ON rel_location_label(labelId);

CREATE TABLE tbl_user
(
    id int identity (1,1) PRIMARY KEY,
    dateCreated datetime,
    dateModified datetime,
    username varchar(50) UNIQUE NOT NULL,
    passwordHash varchar(255) NOT NULL
);
