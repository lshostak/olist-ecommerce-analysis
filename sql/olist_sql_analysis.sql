ALTER TABLE orders ADD COLUMN order_month VARCHAR(7);
ALTER TABLE orders ADD COLUMN order_year INT;
ALTER TABLE orders ADD COLUMN delivery_delay_days INT;
ALTER TABLE orders ADD COLUMN delivery_days_actual INT;

UPDATE orders SET
    order_month = DATE_FORMAT(order_purchase_timestamp, '%Y-%m'),
    order_year  = YEAR(order_purchase_timestamp),
    delivery_delay_days = DATEDIFF(
        order_delivered_customer_date,
        order_estimated_delivery_date
    ),
    delivery_days_actual = DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    ),
    is_late = CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 1 ELSE 0
    END;


-- Q1: Як змінювався GMV щомісяця і яке місяць-до-місяця зростання?
-- GMV = сума всіх платежів (ціна товару + вартість доставки)
WITH monthly_gmv AS (
    SELECT
        o.order_month,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS gmv
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_month
)
SELECT
    order_month,
    total_orders,
    gmv,
    -- GMV попереднього місяця
    LAG(gmv) OVER (ORDER BY order_month) AS prev_month_gmv,
    -- зростання у % до попереднього місяця: (поточний - попередній) / попередній * 100
    ROUND(
        (gmv - LAG(gmv) OVER (ORDER BY order_month))
        / LAG(gmv) OVER (ORDER BY order_month) * 100
    , 2) AS mom_growth_pct
FROM monthly_gmv
ORDER BY order_month;


-- Q2: Який середній чек (AOV) і як він змінювався з часом?
-- AOV = загальна виручка / кількість замовлень
SELECT
    o.order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    -- середній чек = виручка поділена на кількість замовлень
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS aov
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY o.order_month
ORDER BY o.order_month;

-- Q3: Який відсоток замовлень доставлено, скасовано, повернено?
-- SUM(COUNT(*)) OVER() - віконна функція для підрахунку загальної суми
SELECT
    order_status,
    COUNT(*) AS total,
    -- відсоток від загальної кількості замовлень
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM orders
GROUP BY order_status
ORDER BY total DESC;

-- Q4: Як змінювалась кількість нових клієнтів щомісяця?
-- SUM() OVER() - накопичувальний підсумок (running total)
WITH new_customers AS (
    SELECT
        o.order_month,
        COUNT(DISTINCT c.customer_unique_id) AS new_customers
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_month BETWEEN '2016-09' AND '2018-08'
    GROUP BY o.order_month
)
SELECT
    order_month,
    new_customers,
    -- накопичувальна сума клієнтів з першого місяця
    SUM(new_customers) OVER (
        ORDER BY order_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_customers
FROM new_customers
ORDER BY order_month;

-- Q5: Яка частка замовлень доставляється із запізненням по штатах?
-- RANK() - віконна функція для ранжування штатів по затримці
SELECT
    c.customer_state,
    COUNT(*) AS total_orders,
    SUM(o.is_late) AS late_orders,
    -- відсоток запізнілих доставок
    ROUND(SUM(o.is_late) * 100.0 / COUNT(*), 2) AS late_pct,
    ROUND(AVG(o.delivery_delay_days), 1) AS avg_delay_days,
    -- ранжування штатів від найгіршого до найкращого
    RANK() OVER (ORDER BY AVG(o.delivery_delay_days) DESC) AS delay_rank
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY avg_delay_days DESC;

-- Q6: Які штати мають найбільший середній час доставки?
-- RANK() - ранжування штатів від найдовшої до найкоротшої доставки
SELECT
    c.customer_state,
    COUNT(*) AS total_orders,
    ROUND(AVG(o.delivery_days_actual), 1) AS avg_delivery_days,
    -- ранжування від найдовшої доставки
    RANK() OVER (ORDER BY AVG(o.delivery_days_actual) DESC) AS rank_by_delivery
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.delivery_days_actual IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

-- Q7: Топ-10% продавців — яку частку виручки вони генерують? (Парето)
-- NTILE(10) - ділить продавців на 10 рівних груп по виручці
WITH seller_revenue AS (
    SELECT
        oi.seller_id,
        ROUND(SUM(oi.price), 2) AS revenue,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        -- ділимо продавців на 10 груп: 1 = топ 10%, 10 = bottom 10%
        NTILE(10) OVER (ORDER BY SUM(oi.price) DESC) AS decile
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id
)
SELECT
    decile,
    COUNT(*) AS sellers_count,
    ROUND(SUM(revenue), 2) AS total_revenue,
    -- відсоток виручки від загальної суми
    ROUND(
        SUM(revenue) * 100.0 / SUM(SUM(revenue)) OVER ()
    , 2) AS revenue_pct
FROM seller_revenue
GROUP BY decile
ORDER BY decile;

-- Q8: Які категорії товарів найприбутковіші за GMV і AOV?
-- RANK() - ранжування категорій від найбільшого GMV
SELECT
    ct.product_category_name_english AS category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS gmv,
    ROUND(AVG(oi.price), 2) AS aov,
    -- ранжування категорій по загальному GMV
    RANK() OVER (ORDER BY SUM(oi.price) DESC) AS gmv_rank
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY ct.product_category_name_english
ORDER BY gmv DESC
LIMIT 20;

-- Q9: Який розподіл кількості товарів в одному замовленні?
SELECT
    items_count,
    COUNT(*) AS orders_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct,
    ROUND(AVG(order_value), 2) AS avg_order_value
FROM (
    SELECT
        o.order_id,
        COUNT(oi.order_item_id) AS items_count,
        SUM(oi.price) AS order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
) AS order_summary
GROUP BY items_count
ORDER BY items_count;

-- Q10: Яка частка покупців повертається через 30/60/90 днів?
-- Cohort retention аналіз
-- ============================================================
WITH first_order AS (
    -- знаходимо дату першого замовлення кожного клієнта
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_order_date,
        DATE_FORMAT(MIN(o.order_purchase_timestamp), '%Y-%m') AS cohort_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),
orders_with_cohort AS (
    -- рахуємо скільки днів пройшло з першого замовлення
    SELECT
        f.cohort_month,
        f.customer_unique_id,
        DATEDIFF(o.order_purchase_timestamp, f.first_order_date) AS days_since_first
    FROM orders o
    JOIN customers c   ON o.customer_id = c.customer_id
    JOIN first_order f ON c.customer_unique_id = f.customer_unique_id
)
SELECT
    cohort_month,
    COUNT(DISTINCT customer_unique_id) AS cohort_size,
    -- клієнти що повернулись через 30/60/90 днів
    COUNT(DISTINCT CASE WHEN days_since_first BETWEEN 1 AND 30  THEN customer_unique_id END) AS returned_30d,
    COUNT(DISTINCT CASE WHEN days_since_first BETWEEN 1 AND 60  THEN customer_unique_id END) AS returned_60d,
    COUNT(DISTINCT CASE WHEN days_since_first BETWEEN 1 AND 90  THEN customer_unique_id END) AS returned_90d
FROM orders_with_cohort
GROUP BY cohort_month
ORDER BY cohort_month;

-- Q11: Які штати генерують найбільше замовлень і який AOV по регіонах?
-- RANK() - ранжування штатів по GMV
-- ============================================================
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS gmv,
    ROUND(AVG(oi.price), 2) AS aov,
    -- ранжування штатів від найбільшого GMV
    RANK() OVER (ORDER BY SUM(oi.price) DESC) AS gmv_rank
FROM orders o
JOIN customers c   ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY gmv DESC;