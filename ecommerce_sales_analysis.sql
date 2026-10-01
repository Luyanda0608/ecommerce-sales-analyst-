-- E-commerce Sales Analysis
-- Project 1 | SQL Portfolio Project
-- Dataset period: June 2025

-- 1. Overall sales summary
SELECT
    COUNT(orders.order_id) AS total_orders,
    SUM(orders.quantity) AS total_units_sold,
    SUM(orders.quantity * products.price) AS total_revenue
FROM orders
JOIN products
    ON orders.product_id = products.product_id;


-- 2. Product performance
WITH product_revenue AS (
    SELECT
        products.product_name,
        products.category,
        COALESCE(SUM(orders.quantity), 0) AS units_sold,
        COALESCE(SUM(orders.quantity * products.price), 0) AS revenue
    FROM products
    LEFT JOIN orders
        ON products.product_id = orders.product_id
    GROUP BY products.product_name, products.category
)
SELECT
    product_name,
    category,
    units_sold,
    revenue,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM product_revenue
ORDER BY revenue_rank;


-- 3. Customer performance
WITH customer_orders AS (
    SELECT
        customers.name AS customer_name,
        customers.city,
        COUNT(orders.order_id) AS number_of_orders,
        COALESCE(SUM(orders.quantity * products.price), 0) AS total_spending
    FROM customers
    LEFT JOIN orders
        ON customers.customer_id = orders.customer_id
    LEFT JOIN products
        ON orders.product_id = products.product_id
    GROUP BY customers.name, customers.city
)
SELECT
    customer_name,
    city,
    number_of_orders,
    total_spending,
    CASE
        WHEN number_of_orders = 0 THEN 0
        ELSE total_spending / number_of_orders
    END AS average_order_value,
    RANK() OVER (ORDER BY total_spending DESC) AS spending_rank
FROM customer_orders
ORDER BY spending_rank;


-- 4. City performance
SELECT
    customers.city,
    COUNT(DISTINCT customers.customer_id) AS number_of_customers,
    COUNT(orders.order_id) AS total_orders,
    COALESCE(SUM(orders.quantity), 0) AS total_units_sold,
    COALESCE(SUM(orders.quantity * products.price), 0) AS total_revenue,
    RANK() OVER (
        ORDER BY COALESCE(SUM(orders.quantity * products.price), 0) DESC
    ) AS revenue_rank
FROM customers
LEFT JOIN orders
    ON customers.customer_id = orders.customer_id
LEFT JOIN products
    ON orders.product_id = products.product_id
GROUP BY customers.city
ORDER BY revenue_rank;


-- 5. Category performance
WITH category_performance AS (
    SELECT
        products.category,
        COUNT(DISTINCT products.product_id) AS number_of_products,
        COALESCE(SUM(orders.quantity), 0) AS units_sold,
        COALESCE(SUM(orders.quantity * products.price), 0) AS total_revenue
    FROM products
    LEFT JOIN orders
        ON products.product_id = orders.product_id
    GROUP BY products.category
)
SELECT
    category,
    number_of_products,
    units_sold,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM category_performance
ORDER BY revenue_rank;


-- 6. Customers above overall average spending
WITH customer_spending AS (
    SELECT
        customers.name AS customer_name,
        customers.city,
        SUM(orders.quantity * products.price) AS total_spending
    FROM customers
    JOIN orders
        ON customers.customer_id = orders.customer_id
    JOIN products
        ON orders.product_id = products.product_id
    GROUP BY customers.name, customers.city
),
customer_comparison AS (
    SELECT
        customer_name,
        city,
        total_spending,
        AVG(total_spending) OVER () AS average_customer_spending
    FROM customer_spending
)
SELECT
    customer_name,
    city,
    total_spending,
    average_customer_spending
FROM customer_comparison
WHERE total_spending > average_customer_spending
ORDER BY total_spending DESC;


-- 7. Repeat customers
SELECT
    customers.name AS customer_name,
    customers.city,
    COUNT(orders.order_id) AS number_of_orders,
    SUM(orders.quantity * products.price) AS total_spending,
    SUM(orders.quantity * products.price) / COUNT(orders.order_id) AS average_order_value
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
JOIN products
    ON orders.product_id = products.product_id
GROUP BY customers.name, customers.city
HAVING COUNT(orders.order_id) >= 2
ORDER BY total_spending DESC;


-- 8. Customers spending above their city average
WITH customer_spending AS (
    SELECT
        customers.name AS customer_name,
        customers.city,
        SUM(orders.quantity * products.price) AS total_spending
    FROM customers
    JOIN orders
        ON customers.customer_id = orders.customer_id
    JOIN products
        ON orders.product_id = products.product_id
    GROUP BY customers.name, customers.city
),
city_comparison AS (
    SELECT
        customer_name,
        city,
        total_spending,
        AVG(total_spending) OVER (PARTITION BY city) AS city_average_spending
    FROM customer_spending
)
SELECT
    customer_name,
    city,
    total_spending,
    city_average_spending
FROM city_comparison
WHERE total_spending > city_average_spending
ORDER BY city, total_spending DESC;


-- 9. Top product in each category
WITH product_revenue AS (
    SELECT
        products.product_name,
        products.category,
        SUM(orders.quantity * products.price) AS total_revenue
    FROM orders
    JOIN products
        ON orders.product_id = products.product_id
    GROUP BY products.product_name, products.category
),
ranked_products AS (
    SELECT
        product_name,
        category,
        total_revenue,
        RANK() OVER (
            PARTITION BY category
            ORDER BY total_revenue DESC
        ) AS category_rank
    FROM product_revenue
)
SELECT
    product_name,
    category,
    total_revenue
FROM ranked_products
WHERE category_rank = 1
ORDER BY category;


-- 10. Customer revenue contribution
WITH customer_spending AS (
    SELECT
        customers.name AS customer_name,
        customers.city,
        SUM(orders.quantity * products.price) AS total_spending
    FROM customers
    JOIN orders
        ON customers.customer_id = orders.customer_id
    JOIN products
        ON orders.product_id = products.product_id
    GROUP BY customers.name, customers.city
)
SELECT
    customer_name,
    city,
    total_spending,
    total_spending * 100.0 / SUM(total_spending) OVER () AS revenue_percentage
FROM customer_spending
ORDER BY revenue_percentage DESC;


-- 11. Daily and running revenue
WITH june_revenue AS (
    SELECT
        orders.order_date,
        SUM(orders.quantity * products.price) AS daily_revenue
    FROM orders
    JOIN products
        ON orders.product_id = products.product_id
    GROUP BY orders.order_date
)
SELECT
    order_date,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY order_date) AS running_revenue
FROM june_revenue
ORDER BY order_date;


-- 12. Product revenue sequence using LAG
WITH product_performance AS (
    SELECT
        products.product_name,
        products.category,
        SUM(orders.quantity * products.price) AS total_revenue
    FROM orders
    JOIN products
        ON orders.product_id = products.product_id
    GROUP BY products.product_name, products.category
),
product_sequence AS (
    SELECT
        product_name,
        category,
        total_revenue,
        LAG(total_revenue) OVER (
            PARTITION BY category
            ORDER BY total_revenue DESC
        ) AS previous_product_revenue
    FROM product_performance
)
SELECT
    product_name,
    category,
    total_revenue,
    previous_product_revenue,
    total_revenue - previous_product_revenue AS revenue_difference
FROM product_sequence
ORDER BY category, total_revenue DESC;


-- 13. Customer purchase timing
WITH purchase_timing AS (
    SELECT
        customers.name AS customer_name,
        customers.signup_date,
        MIN(orders.order_date) AS first_order_date
    FROM customers
    LEFT JOIN orders
        ON customers.customer_id = orders.customer_id
    GROUP BY customers.name, customers.signup_date
)
SELECT
    customer_name,
    signup_date,
    first_order_date,
    first_order_date - signup_date AS days_to_first_order
FROM purchase_timing
ORDER BY first_order_date ASC;


-- 14. Customers with a second purchase within 14 days
WITH customer_orders AS (
    SELECT
        customers.name AS customer_name,
        orders.order_date AS first_order_date,
        LEAD(orders.order_date) OVER (
            PARTITION BY customers.name
            ORDER BY orders.order_date ASC
        ) AS second_order_date
    FROM customers
    JOIN orders
        ON customers.customer_id = orders.customer_id
)
SELECT
    customer_name,
    first_order_date,
    second_order_date,
    second_order_date - first_order_date AS days_between_orders
FROM customer_orders
WHERE second_order_date - first_order_date <= 14
ORDER BY customer_name, first_order_date;


-- 15. Order gaps greater than 10 days for customers with at least 3 orders
WITH customer_orders AS (
    SELECT
        customers.name AS customer_name,
        orders.order_date,
        LAG(orders.order_date) OVER (
            PARTITION BY customers.name
            ORDER BY orders.order_date ASC
        ) AS previous_order_date,
        COUNT(*) OVER (
            PARTITION BY customers.name
        ) AS order_count
    FROM customers
    JOIN orders
        ON customers.customer_id = orders.customer_id
),
order_gaps AS (
    SELECT
        customer_name,
        order_date,
        previous_order_date,
        order_date - previous_order_date AS days_since_previous_order
    FROM customer_orders
    WHERE order_count >= 3
)
SELECT
    customer_name,
    order_date,
    previous_order_date,
    days_since_previous_order
FROM order_gaps
WHERE days_since_previous_order > 10
ORDER BY customer_name, order_date;


-- 16. High-value repeat customers
WITH customer_spending AS (
    SELECT
        customers.name AS customer_name,
        customers.city,
        COUNT(orders.order_id) AS number_of_orders,
        SUM(orders.quantity * products.price) AS total_spending
    FROM customers
    JOIN orders
        ON customers.customer_id = orders.customer_id
    JOIN products
        ON orders.product_id = products.product_id
    GROUP BY customers.name, customers.city
),
customer_comparison AS (
    SELECT
        customer_name,
        city,
        total_spending,
        number_of_orders,
        AVG(total_spending) OVER () AS average_customer_spending
    FROM customer_spending
)
SELECT
    customer_name,
    city,
    total_spending,
    number_of_orders,
    average_customer_spending,
    RANK() OVER (ORDER BY total_spending DESC) AS customer_rank
FROM customer_comparison
WHERE number_of_orders >= 2
  AND total_spending > average_customer_spending
ORDER BY customer_rank;


-- 17. Final management summary
WITH sales_summary AS (
    SELECT
        COUNT(orders.order_id) AS total_orders,
        SUM(orders.quantity) AS total_units_sold,
        SUM(orders.quantity * products.price) AS total_revenue,
        COUNT(DISTINCT orders.customer_id) AS customers_with_orders
    FROM orders
    JOIN products
        ON orders.product_id = products.product_id
),
customer_summary AS (
    SELECT COUNT(*) AS total_customers
    FROM customers
)
SELECT
    customer_summary.total_customers,
    sales_summary.customers_with_orders,
    sales_summary.total_orders,
    sales_summary.total_units_sold,
    sales_summary.total_revenue,
    sales_summary.total_revenue / sales_summary.total_orders AS average_order_value
FROM sales_summary
CROSS JOIN customer_summary;
