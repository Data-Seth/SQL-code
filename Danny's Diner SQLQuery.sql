SELECT *
FROM sales;

SELECT *
FROM menu;

SELECT *
FROM members;

--What is the total amount each customer spent at the restaurant?

SELECT S.customer_id, SUM(price) TotalCustomerExpenditure
FROM sales S
JOIN menu M
ON S.product_id = M.product_id
FULL JOIN members ME
ON S.customer_id = ME.customer_id
GROUP BY S.customer_id;

--How many days has each customer visited the restaurant?

SELECT S.customer_id, COUNT(DISTINCT(order_date)) NumberOfDaysVisited
FROM sales S
JOIN menu M
ON S.product_id = M.product_id
FULL JOIN members ME
ON S.customer_id = ME.customer_id
GROUP BY S.customer_id;

--What was the first item from the menu purchased by each customer?

WITH FIRST_ITEM AS (
SELECT S.customer_id, join_date, order_date, S.product_id, product_name, price
, ROW_NUMBER() OVER(PARTITION BY S.customer_id ORDER BY order_date) AS ROW_NUM
FROM sales S
JOIN menu M
ON S.product_id = M.product_id
FULL JOIN members ME
ON S.customer_id = ME.customer_id
)
SELECT *
FROM FIRST_ITEM
WHERE ROW_NUM = '1';

--What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name, COUNT(product_name) PurchaseCount
FROM sales S
JOIN menu M
ON S.product_id = M.product_id
FULL JOIN members ME
ON S.customer_id = ME.customer_id
GROUP BY product_name
ORDER BY 2
OFFSET 2 ROWS
FETCH NEXT 1 ROW ONLY;

--Which item was the most popular for each customer?

SELECT S.customer_id, product_name, (S.product_id) 
FROM sales S
JOIN menu M
ON S.product_id = M.product_id
FULL JOIN members ME
ON S.customer_id = ME.customer_id
GROUP BY product_name, S.customer_id

--Which item was purchased first by the customer after they became a member?

WITH FIR_PUR AS(
SELECT S.customer_id, order_date, product_name, join_date
, ROW_NUMBER() OVER(PARTITION BY S.customer_id ORDER BY order_date) ROW_NUM
FROM sales S
JOIN menu M
ON S.product_id = M.product_id
FULL JOIN members ME
ON S.customer_id = ME.customer_id
WHERE join_date <= order_date
)
SELECT customer_id, order_date, product_name, join_date
FROM FIR_PUR
WHERE ROW_NUM = '1';

--Which item was purchased just before the customer became a member?

SELECT *
FROM sales S
JOIN menu M
ON S.product_id = M.product_id
FULL JOIN members ME
ON S.customer_id = ME.customer_id
--GROUP BY product_name, S.customer_id