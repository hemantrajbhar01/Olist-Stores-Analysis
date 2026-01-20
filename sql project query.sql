create database Olist_dataset ;
use olist_dataset;
select * from olist_customers_dataset;
select * from olist_geolocation_dataset;

SELECT 
    table_name,
    table_rows
FROM information_schema.tables
WHERE table_schema = 'olist_dataset';

# Total Orders
select count(distinct order_id) from Olist_orders_dataset;

# Total Customers
select count(distinct customer_id) from olist_customers_dataset;

# Total Payments
select sum(payment_value) from olist_order_payments_Dataset;

# Total Sellers
select count(distinct seller_id) from olist_sellers_dataset;

#KPI 1 Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
 SET SQL_SAFE_UPDATES = 0;

UPDATE olist_orders_dataset
SET order_purchase_timestamp =
STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s');

ALTER TABLE olist_orders_dataset
MODIFY order_purchase_timestamp DATETIME;

SET SQL_SAFE_UPDATES = 1;

SELECT 
  CASE 
    WHEN DAYOFWEEK(o.order_purchase_timestamp) IN (1,7) THEN 'Weekend'
    ELSE 'Weekday'
  END AS day_type,
  ROUND(SUM(p.payment_value) * 100 /
       (SELECT SUM(payment_value) FROM olist_order_payments_dataset), 2) AS payment_percent
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
  ON o.order_id = p.order_id
GROUP BY day_type;

#KPI 2 Number of Orders with review score 5 and payment type as credit card.

  select count(distinct p.order_id) as NumberOfOrders
from Olist_order_payments_dataset p
join olist_order_reviews_dataset r on p.order_id=r.order_id
where r.Review_score =5 and p.payment_type='credit_card';
  

#KPI 3 
  select
product_category_name,
round(avg(datediff(Order_delivered_customer_date,order_purchase_timestamp))) as avg_delivery_time
from OLIST_orders_DATASET o join olist_order_items_dataset i on i.order_id=o.order_id
join olist_products_dataset p on p.product_id=i.product_id
where
p.product_category_name = 'pet_shop'
and o.Order_delivered_customer_date is not null;



#KPI 4 Average price and payment values from customers of sao paulo city

select
round(avg(i.price)) as average_price,
round(avg(p.payment_value)) as average_payment
from olist_customers_dataset c
join Olist_orders_dataset o on c.customer_id=o.Customer_id
join olist_order_items_dataset i on o.order_id=i.order_id
join Olist_order_payments_dataset p on o.order_id=p.order_id
where Customer_city ='Sao Paulo';


#KPI 5 Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

SET SQL_SAFE_UPDATES = 0;

UPDATE olist_orders_dataset
SET order_delivered_customer_date = NULL
WHERE order_delivered_customer_date = '';

UPDATE olist_orders_dataset
SET
  order_purchase_timestamp =
    STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'),
  order_delivered_customer_date =
    STR_TO_DATE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s')
WHERE order_purchase_timestamp IS NOT NULL
   OR order_delivered_customer_date IS NOT NULL;


ALTER TABLE olist_orders_dataset
MODIFY order_purchase_timestamp DATETIME,
MODIFY order_delivered_customer_date DATETIME;


SELECT
  DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS days
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL
LIMIT 5;

SELECT
  r.review_score,
  AVG(DATEDIFF(o.order_delivered_customer_date,
               o.order_purchase_timestamp)) AS avg_shipping_days
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
  ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score;






