CREATE DATABASE abztract;

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
    name varchar(100),
    units_name varchar(50),
    is_set bit,
    status_id int NOT NULL REFERENCES cat_status
);

CREATE INDEX cat_product_status_id ON cat_product(status_id);

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
    product_id int NOT NULL REFERENCES cat_product,
    attribute_id int NOT NULL REFERENCES tbl_attribute
);

CREATE INDEX rel_product_attribute_product_id ON rel_product_attribute(product_id);
CREATE INDEX rel_product_attribute_attribute_id ON rel_product_attribute(attribute_id);

CREATE TABLE tbl_product(
    id int identity (1,1) PRIMARY KEY,
    date_created datetime,
    date_modified datetime,
    product_id int NOT NULL REFERENCES cat_product,
    document_number varchar(30),
    supplier_number varchar(30),
    material_id int NOT NULL REFERENCES cat_material,
    quantity float,
    unit_value float,
    grammage float,
    width float,
    lenght float,
    height float,
    is_printed bit,
    is_waxed bit,
    company_id int NOT NULL REFERENCES cat_company,
    cost float,
    currency_id int NOT NULL REFERENCES cat_currency,
    exchange_rate float,
    specific_attribute varchar(MAX),
    manufacturer_id int NOT NULL REFERENCES cat_manufacturer
);

CREATE INDEX tbl_product_product_id ON tbl_product(product_id);
CREATE INDEX tbl_product_material_id ON tbl_product(material_id);
CREATE INDEX tbl_product_company_id ON tbl_product(company_id);
CREATE INDEX tbl_product_currency_id ON tbl_product(currency_id);
CREATE INDEX tbl_product_manufacturer_id ON tbl_product(manufacturer_id);

CREATE TABLE tbl_value(
    id int identity (1,1) PRIMARY KEY,
    date_created datetime,
    date_modified datetime,
    attribute_id int NOT NULL REFERENCES tbl_attribute,
    product_id int NOT NULL REFERENCES cat_product
);

CREATE INDEX tbl_value_attribute_id ON tbl_value(attribute_id);
CREATE INDEX tbl_value_product_id ON tbl_value(product_id);