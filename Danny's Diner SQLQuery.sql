--Displaying the table values

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
GROUP BY product_name, S.customer_id;

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

WITH LAST_MEM AS
(
SELECT S.customer_id, order_date, product_name, join_date
, MAX(order_date) OVER(PARTITION BY S.customer_id) AS last_order_before_membership
FROM sales S
JOIN menu M
ON S.product_id = M.product_id
FULL JOIN members ME
ON S.customer_id = ME.customer_id
WHERE join_date > order_date
)
SELECT customer_id, MAX(last_order_before_membership) AS last_order_before_membership
FROM LAST_MEM
GROUP BY customer_id;

--What is the total items and amount spent for each member before they became a member?

SELECT S.customer_id, SUM(price) AS amount_spent_before_membership
FROM sales S
JOIN menu M
ON S.product_id = M.product_id
FULL JOIN members ME
ON S.customer_id = ME.customer_id
WHERE join_date > order_date
GROUP BY S.customer_id;

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH NUMBER_OF_POINTS AS
(
SELECT S.customer_id
,CASE
	WHEN product_name = 'sushi' THEN price * 20
	ELSE price * 10
END AS number_of_points
FROM sales S
JOIN menu M
ON S.product_id = M.product_id
FULL JOIN members ME
ON S.customer_id = ME.customer_id
)
SELECT customer_id, SUM(number_of_points) AS number_of_points
FROM NUMBER_OF_POINTS
GROUP BY customer_id;

--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi -
--how many points do customer A and B have at the end of January?

WITH NUMBER_OF_POINTS AS
(
SELECT S.customer_id, S.order_date, price
,CASE
	WHEN DAY(order_date) BETWEEN DAY(join_date) AND DAY(join_date) + 7 THEN price * 20
	ELSE price * 10
END AS number_of_points
FROM sales S
JOIN menu M
ON S.product_id = M.product_id
FULL JOIN members ME
ON S.customer_id = ME.customer_id
WHERE order_date < '2021-01-31'
)
SELECT customer_id, SUM(number_of_points) AS number_of_points
FROM NUMBER_OF_POINTS
GROUP BY customer_id
ORDER BY customer_id DESC
OFFSET 1 ROW
FETCH NEXT 2 ROW ONLY;
