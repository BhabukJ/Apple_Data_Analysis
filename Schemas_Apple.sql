create database Apple;
DROP TABLE IF EXISTS stores;
CREATE TABLE stores(
store_id VARCHAR(5) PRIMARY KEY,
store_name	VARCHAR(30),
city	VARCHAR(25),
country VARCHAR(25)
);
--Inserting data into the stores table
INSERT INTO stores(store_id,store_name,city,country)
select store_id,store_name,city,country from store

select  * from stores;

DROP TABLE IF EXISTS category;
CREATE TABLE category
(category_id VARCHAR(10) PRIMARY KEY,
category_name VARCHAR(20)
);


INSERT INTO category (category_id,category_name)
SELECT category_id,category_name FROM categorys

DROP TABLE IF EXISTS products;
CREATE TABLE products
(
product_id	VARCHAR(10) PRIMARY KEY,
product_name	VARCHAR(35),
category_id	VARCHAR(10),
launch_date	date,
price FLOAT,
CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES category(category_id)
);

INSERT  INTO products (product_id,product_name,category_id,launch_date,price)
SELECT  product_id,product_name,category_id,launch_date,price FROM product
select  * from products;

DROP TABLE IF EXISTS sales;
CREATE TABLE sales
(
sale_id	VARCHAR(15) PRIMARY KEY,
sale_date	DATE,
store_id	VARCHAR(5),
product_id	VARCHAR(10), 
quantity INT,
CONSTRAINT fk_store FOREIGN KEY (store_id) REFERENCES stores(store_id),
CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO sales (sale_id,sale_date,store_id,product_id,quantity)
SELECT sale_id,sale_date,store_id,product_id,quantity from sales_data;
select top 5 * from sales;

DROP TABLE IF EXISTS warranty;

CREATE TABLE warranty
(
claim_id VARCHAR(10) PRIMARY KEY,	
claim_date	date,
sale_id	VARCHAR(15),
repair_status VARCHAR(15),
CONSTRAINT fk_orders FOREIGN KEY (sale_id) REFERENCES sales(sale_id)
);

INSERT INTO warranty (claim_id,claim_date,sale_id,repair_status)
SELECT claim_id,claim_date,sale_id,repair_status FROM warrantys;


