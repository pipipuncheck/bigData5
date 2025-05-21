CREATE SCHEMA sales_mart;

-- Продукты: самые продаваемые
CREATE VIEW sales_mart.products_most_saling AS
SELECT
    sale_product_id AS product_id,
    product_name,
    SUM(sale_quantity) AS sales_count
FROM sales
GROUP BY sale_product_id, product_name;

-- Продукты: общая сумма по категориям
CREATE VIEW sales_mart.products_total_price_by_categories AS
SELECT
    product_category AS category_name,
    SUM(sale_total_price) AS total_price
FROM sales
GROUP BY product_category;

-- Продукты: средний рейтинг и количество отзывов
CREATE VIEW sales_mart.products_average_rating_and_reviews AS
SELECT
    sale_product_id AS product_id,
    product_name,
    AVG(product_rating) AS rating,
    SUM(product_reviews) AS reviews
FROM sales
GROUP BY sale_product_id, product_name;

-- Клиенты: самые покупающие
CREATE VIEW sales_mart.customers_most_buying AS
SELECT
    sale_customer_id AS customer_id,
    customer_first_name,
    customer_last_name,
    customer_email,
    SUM(sale_total_price) AS total_price
FROM sales
GROUP BY sale_customer_id, customer_first_name, customer_last_name, customer_email;

-- Клиенты: распределение по странам
CREATE VIEW sales_mart.customers_distribution_by_countries AS
SELECT
    customer_country AS country,
    COUNT(DISTINCT sale_customer_id) AS customers_quantity,
    COUNT(DISTINCT sale_customer_id) * 100.0 / (SELECT COUNT(*) FROM sales) AS share
FROM sales
GROUP BY customer_country;

-- Клиенты: средняя цена покупки
CREATE VIEW sales_mart.customers_average_price AS
SELECT
    sale_customer_id AS customer_id,
    customer_first_name,
    customer_last_name,
    AVG(sale_total_price) AS average_price
FROM sales
GROUP BY sale_customer_id, customer_first_name, customer_last_name;

-- Время: тренды по месяцам
CREATE VIEW sales_mart.time_monthly_trends AS
SELECT
    DATE_TRUNC('month', TO_DATE(sale_date, 'YYYY-MM-DD')) AS month,
    SUM(CAST(sale_total_price AS NUMERIC)) AS total_price,
    COUNT(*) AS sales_count
FROM sales
GROUP BY DATE_TRUNC('month', TO_DATE(sale_date, 'YYYY-MM-DD'));

-- Время: месяц к месяцу (Month-over-Month)
CREATE VIEW sales_mart.time_month_over_month AS
WITH trends AS (
    SELECT
        DATE_TRUNC('month', TO_DATE(sale_date, 'YYYY-MM-DD')) AS month,
        SUM(CAST(sale_total_price AS NUMERIC)) AS total_price,
        COUNT(*) AS sales_count
    FROM sales
    GROUP BY DATE_TRUNC('month', TO_DATE(sale_date, 'YYYY-MM-DD'))
)
SELECT
    month,
    total_price,
    sales_count,
    total_price - LAG(total_price) OVER (ORDER BY month) AS m_o_m_change,
    (total_price - LAG(total_price) OVER (ORDER BY month)) * 100.0 / LAG(total_price) OVER (ORDER BY month) AS m_o_m_change_share
FROM trends;

-- Время: среднее количество продаж по месяцам
CREATE VIEW sales_mart.time_average_sales_by_month AS
SELECT
    DATE_TRUNC('month', TO_DATE(sale_date, 'YYYY-MM-DD')) AS month,
    AVG(CAST(sale_quantity AS NUMERIC)) AS average_sales_quantity
FROM sales
GROUP BY DATE_TRUNC('month', TO_DATE(sale_date, 'YYYY-MM-DD'));

-- Магазины: топ-5 магазинов по цене
CREATE VIEW sales_mart.stores_top5_by_price AS
SELECT
    store_name,
    SUM(sale_total_price) AS total_price
FROM sales
GROUP BY store_name
ORDER BY total_price DESC
LIMIT 5;

-- Магазины: распределение по странам
CREATE VIEW sales_mart.stores_sales_distribution_by_countries AS
SELECT
    store_country AS country,
    SUM(sale_quantity) AS sales_quantity,
    SUM(sale_quantity) * 100.0 / (SELECT SUM(sale_quantity) FROM sales) AS share
FROM sales
GROUP BY store_country;

-- Магазины: средняя цена
CREATE VIEW sales_mart.stores_average_price AS
SELECT
    store_name,
    AVG(sale_total_price) AS average_price
FROM sales
GROUP BY store_name;

-- Поставщики: топ-5 поставщиков по цене
CREATE VIEW sales_mart.suppliers_top5_by_price AS
SELECT
    supplier_name,
    SUM(sale_total_price) AS total_price
FROM sales
GROUP BY supplier_name
ORDER BY total_price DESC
LIMIT 5;

-- Поставщики: средняя цена продукции
CREATE VIEW sales_mart.suppliers_average_product_price AS
SELECT
    supplier_name,
    AVG(product_price) AS average_product_price
FROM sales
GROUP BY supplier_name;

-- Поставщики: распределение по странам
CREATE VIEW sales_mart.suppliers_sales_distribution_by_countries AS
SELECT
    supplier_country AS country,
    SUM(sale_quantity) AS sales_quantity,
    SUM(sale_quantity) * 100.0 / (SELECT SUM(sale_quantity) FROM sales) AS share
FROM sales
GROUP BY supplier_country;

-- Качество продукции: самые рейтинговые продукты
CREATE VIEW sales_mart.quality_most_rating_products AS
SELECT
    sale_product_id AS product_id,
    product_name,
    MAX(product_rating) AS rating
FROM sales
GROUP BY sale_product_id, product_name;

-- Качество продукции: наименее рейтинговые продукты
CREATE VIEW sales_mart.quality_least_rating_products AS
SELECT
    sale_product_id AS product_id,
    product_name,
    MIN(product_rating) AS rating
FROM sales
GROUP BY sale_product_id, product_name;

-- Качество продукции: корреляция между рейтингом и продажами
CREATE VIEW sales_mart.quality_rating_sales_correlation AS
SELECT
    CORR(product_rating, sale_total_price) AS correlation
FROM sales;

-- Качество продукции: самые обсуждаемые продукты
CREATE VIEW sales_mart.quality_most_reviewed_products AS
SELECT
    sale_product_id AS product_id,
    product_name,
    SUM(product_reviews) AS reviews
FROM sales
GROUP BY sale_product_id, product_name;
