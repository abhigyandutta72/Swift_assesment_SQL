CREATE TABLE Sales_Data
(
	sl_no int,
	SKU_NAME varchar,
	FEED_DATE date,
	CATEGORY varchar,
	SUB_CATEGORY varchar,
	ORDERED_REVENUE float,
	ORDERED_UNITS int,
	REP_OOS float
);
 
SELECT *from Sales_data
CREATE TABLE Glance_Views
(
	sl_no int,
	SKU_NAME varchar,
	FEED_DATE date,
	VIEWS int,
	UNITS int
);
SELECT*FROM Glance_Views

Q1.
SELECT
    SKU_NAME,
    AVG(ORDERED_REVENUE) AS average_revenue
FROM
    sales_data
GROUP BY
    SKU_NAME
ORDER BY
    average_revenue DESC
LIMIT 1;


Q2.
WITH total_skus AS (
    SELECT COUNT(DISTINCT SKU_NAME) AS total_count
    FROM sales_data
),
revenue_skus AS (
    SELECT COUNT(DISTINCT SKU_NAME) AS revenue_count
    FROM sales_data
    WHERE ORDERED_REVENUE > 0
)
SELECT
    (revenue_skus.revenue_count::decimal / total_skus.total_count) * 100 AS revenue_percentage
FROM
    total_skus,
    revenue_skus;

Q.brownie
WITH before_july AS (
    SELECT DISTINCT SKU_NAME
    FROM sales_data
    WHERE FEED_DATE < '2019-07-01'
      AND ORDERED_REVENUE > 0
      AND SKU_NAME IS NOT NULL
),
after_july AS (
    SELECT DISTINCT SKU_NAME
    FROM sales_data
    WHERE FEED_DATE >= '2019-07-01'
      AND ORDERED_REVENUE > 0
      AND SKU_NAME IS NOT NULL
),
stopped_selling_skus AS (
    SELECT LOWER(SKU_NAME) AS SKU_NAME
    FROM before_july
    EXCEPT
    SELECT LOWER(SKU_NAME) AS SKU_NAME
    FROM after_july
)
SELECT * 
FROM stopped_selling_skus;


Q3.
WITH daily_data AS (
    SELECT 
        FEED_DATE, 
        SUM(ORDERED_REVENUE) AS total_revenue, 
        SUM(ORDERED_UNITS) AS total_units
    FROM sales_data
    GROUP BY FEED_DATE
),
spike_detection AS (
    SELECT 
        FEED_DATE,
        total_revenue,
        total_units,
        LAG(total_revenue) OVER (ORDER BY FEED_DATE) AS prev_day_revenue,
        LAG(total_units) OVER (ORDER BY FEED_DATE) AS prev_day_units
    FROM daily_data
)
SELECT 
    FEED_DATE,
    total_revenue,
    total_units
FROM spike_detection
WHERE 
    (total_revenue > prev_day_revenue * 1.5 OR total_units > prev_day_units * 1.5)
ORDER BY FEED_DATE;
SELECT SKU_NAME
FROM stopped_selling_skus;


Q4.
WITH daily_data AS (
    SELECT
        FEED_DATE,
        SUM(ORDERED_REVENUE) AS total_revenue,
        SUM(ORDERED_UNITS) AS total_units
    FROM sales_data
    GROUP BY FEED_DATE
),
cannibalization_detection AS (
    SELECT
        FEED_DATE,
        total_revenue,
        total_units,
        LEAD(total_revenue, 2) OVER (ORDER BY FEED_DATE) AS next_day_revenue,
        LEAD(total_units, 2) OVER (ORDER BY FEED_DATE) AS next_day_units
    FROM daily_data 
    WHERE FEED_DATE IN (
        '2019-05-06', '2019-05-13', '2019-05-20', '2019-05-28', '2019-06-03',
        '2019-06-10', '2019-06-17', '2019-06-20', '2019-06-24', '2019-07-01',
        '2019-07-05', '2019-07-08', '2019-07-15', '2019-07-22', '2019-07-26',
        '2019-07-29', '2019-08-05', '2019-08-12', '2019-08-19', '2019-08-26'
    )
)
SELECT
    FEED_DATE,
    total_revenue,
    total_units,
    next_day_revenue,
    next_day_units
FROM cannibalization_detection
WHERE
    (total_revenue > next_day_revenue * 1.2)
    OR (total_units > next_day_units * 1.2)
ORDER BY FEED_DATE;


Q5.
WITH SubcategoryGrowth AS (
    SELECT
        CATEGORY,
        SUB_CATEGORY,
        (MAX(ORDERED_REVENUE) - MIN(ORDERED_REVENUE)) / NULLIF(MIN(ORDERED_REVENUE), 0) AS revenue_growth,
        (MAX(ORDERED_UNITS) - MIN(ORDERED_UNITS)) / NULLIF(MIN(ORDERED_UNITS), 0) AS units_growth
    FROM Sales_Data
    GROUP BY CATEGORY, SUB_CATEGORY
),
CategoryGrowth AS (
    SELECT
        CATEGORY,
        (MAX(ORDERED_REVENUE) - MIN(ORDERED_REVENUE)) / NULLIF(MIN(ORDERED_REVENUE), 0) AS category_revenue_growth,
        (MAX(ORDERED_UNITS) - MIN(ORDERED_UNITS)) / NULLIF(MIN(ORDERED_UNITS), 0) AS category_units_growth
    FROM Sales_Data
    GROUP BY CATEGORY
),
RankedSubcategories AS (
    SELECT
        sg.CATEGORY,
        sg.SUB_CATEGORY,
        ROW_NUMBER() OVER (PARTITION BY sg.CATEGORY ORDER BY sg.revenue_growth ASC, sg.units_growth ASC) AS rank
    FROM SubcategoryGrowth sg
    JOIN CategoryGrowth cg ON sg.CATEGORY = cg.CATEGORY
)
SELECT
    CATEGORY,
    SUB_CATEGORY,
FROM RankedSubcategories
WHERE rank = 1
ORDER BY CATEGORY;




----------------------------------------
Q6.
SELECT 
    COUNT(*) AS missing_values_count
FROM sales_data
WHERE SKU_NAME IS NULL 
   OR ORDERED_REVENUE IS NULL 
   OR ORDERED_UNITS IS NULL 
   OR FEED_DATE IS NULL;
----------------------------------------
SELECT 
    FEED_DATE
FROM sales_data
WHERE FEED_DATE > CURRENT_DATE 
   OR FEED_DATE < '2000-01-01' 
GROUP BY FEED_DATE
HAVING COUNT(*) > 1;
----------------------------------------
SELECT 
    SKU_NAME, 
    FEED_DATE, 
    COUNT(*) AS duplicate_count
FROM sales_data
GROUP BY SKU_NAME, FEED_DATE
HAVING COUNT(*) > 1;


Q7
--Polynomial Regression
WITH sku_sales AS (
    SELECT
        s.SKU_NAME,
        SUM(s.ORDERED_UNITS) AS total_units,
        SUM(s.ORDERED_REVENUE) AS total_revenue,
        gv.VIEWS AS total_views
    FROM
        sales_data s
    JOIN
        glance_views gv ON s.SKU_NAME = gv.SKU_NAME
    WHERE
        s.SKU_NAME = 'C120[H:8NV'
    GROUP BY
        s.SKU_NAME, gv.VIEWS
),
unit_conversion AS (
    SELECT
        SKU_NAME,
        total_units / total_views AS unit_conversion, 
        total_revenue / total_units AS avg_selling_price 
    FROM
        sku_sales
)
SELECT
	REGR_SLOPE(unit_conversion, avg_selling_price * avg_selling_price) AS slope_squared,
    REGR_INTERCEPT(unit_conversion, avg_selling_price) AS intercept,
    REGR_R2(unit_conversion, avg_selling_price) AS r_squared
FROM
    unit_conversion;
----Linear Regression
WITH sku_sales AS (
    SELECT
        s.SKU_NAME,
        SUM(s.ORDERED_UNITS) AS total_units,
        SUM(s.ORDERED_REVENUE) AS total_revenue,
        gv.VIEWS AS total_views
    FROM
        sales_data s
    JOIN
        glance_views gv ON s.SKU_NAME = gv.SKU_NAME
    WHERE
        s.SKU_NAME = 'C120[H:8NV'
    GROUP BY
        s.SKU_NAME, gv.VIEWS
),
unit_conversion AS (
    SELECT
        SKU_NAME,
        total_units / total_views AS unit_conversion,
        total_revenue / total_units AS avg_selling_price 
    FROM
        sku_sales
)
SELECT
    REGR_SLOPE(unit_conversion, avg_selling_price) AS slope,
    REGR_INTERCEPT(unit_conversion, avg_selling_price) AS intercept,
    REGR_R2(unit_conversion, avg_selling_price) AS r_squared
FROM
    unit_conversion;
---------------------------------
--IGNORE
Test:
WITH SubcategoryGrowth AS (
    -- Calculate total revenue and units growth for each subcategory over time
    SELECT
        CATEGORY,
        SUB_CATEGORY,
        (MAX(ORDERED_REVENUE) - MIN(ORDERED_REVENUE)) / NULLIF(MIN(ORDERED_REVENUE), 0) AS revenue_growth,
        (MAX(ORDERED_UNITS) - MIN(ORDERED_UNITS)) / NULLIF(MIN(ORDERED_UNITS), 0) AS units_growth
    FROM Sales_Data
    GROUP BY CATEGORY, SUB_CATEGORY
),
CategoryGrowth AS (
    -- Calculate overall category growth (using either revenue or units for consistency)
    SELECT
        CATEGORY,
        (MAX(ORDERED_REVENUE) - MIN(ORDERED_REVENUE)) / NULLIF(MIN(ORDERED_REVENUE), 0) AS category_revenue_growth,
        (MAX(ORDERED_UNITS) - MIN(ORDERED_UNITS)) / NULLIF(MIN(ORDERED_UNITS), 0) AS category_units_growth
    FROM Sales_Data
    GROUP BY CATEGORY
),
RelativeGrowth AS (
    -- Calculate the relative growth of each subcategory compared to its category
    SELECT
        sg.CATEGORY,
        sg.SUB_CATEGORY,
        sg.revenue_growth / NULLIF(cg.category_revenue_growth, 0) AS relative_revenue_growth,
        sg.units_growth / NULLIF(cg.category_units_growth, 0) AS relative_units_growth
    FROM SubcategoryGrowth sg
    JOIN CategoryGrowth cg ON sg.CATEGORY = cg.CATEGORY
),
RankedSubcategories AS (
    -- Rank subcategories based on their relative growth within each category
    SELECT
        rg.CATEGORY,
        rg.SUB_CATEGORY,
        rg.relative_revenue_growth,
        rg.relative_units_growth,
        RANK() OVER (PARTITION BY rg.CATEGORY ORDER BY rg.relative_revenue_growth ASC) AS revenue_rank,
        RANK() OVER (PARTITION BY rg.CATEGORY ORDER BY rg.relative_units_growth ASC) AS units_rank
    FROM RelativeGrowth rg
)
-- Select the subcategory with the slowest relative growth (lowest rank) per category
SELECT
    CATEGORY,
    SUB_CATEGORY,
    relative_revenue_growth,
    relative_units_growth
FROM RankedSubcategories
WHERE revenue_rank = 1 OR units_rank = 1
ORDER BY CATEGORY;












