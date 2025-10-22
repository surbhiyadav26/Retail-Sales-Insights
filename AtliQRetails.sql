use retail_events_db;
-- select * from fact_events
-- Products whose base price is geater then 500 with BOGO promo

SELECT distinct(p.product_name) , e.base_price
FROM fact_events e
JOIN dim_products p
ON p.product_code = e.product_code
where e.base_price > 500
AND e.promo_type = 'BOGOF';

-- Store count in each city
select city , COUNT(distinct(store_id))
from dim_stores
GROUP BY city
ORDER BY COUNT(distinct(store_id)) DESC;

-- campaign with before and after total revenve
-- select distinct(promo_type) from fact_events
SELECT campaign_name,
	ROUND(SUM(`quantity_sold(before_promo)` * base_price)/1000000,2)AS total_revenue_beforepromo,
    ROUND(SUM(CASE
				WHEN promo_type = 'BOGOF' THEN base_price* `quantity_sold(after_promo)` *2
                WHEN promo_type = '500 Cashback' THEN (base_price-500)* `quantity_sold(after_promo)`
				WHEN promo_type = '50% OFF' THEN base_price* 0.5 * `quantity_sold(after_promo)`
                WHEN promo_type = '25%' THEN base_price * 0.75 * `quantity_sold(after_promo)`
				WHEN promo_type = '33%' THEN base_price* 0.67 * `quantity_sold(after_promo)`
				END
                )/1000000,2) AS total_revenue_afterpromo
from fact_events
JOIN dim_campaigns USING (campaign_id)
GROUP BY campaign_name;

-- ISU% of category during diwali campaign
SELECT 
    p.category, 
    c.campaign_name,
    ROUND(
        ((SUM(`quantity_sold(after_promo)`) - SUM(`quantity_sold(before_promo)`)) 
        / SUM(`quantity_sold(before_promo)`) * 100),
        2
    ) AS 'ISU%',
    RANK() OVER (
        ORDER BY 
        ((SUM(`quantity_sold(after_promo)`) - SUM(`quantity_sold(before_promo)`)) 
        / SUM(`quantity_sold(before_promo)`) * 100) DESC
    ) AS rank_isu
FROM fact_events
JOIN dim_products p USING (product_code)
JOIN dim_campaigns c USING (campaign_id)
WHERE c.campaign_name = 'Diwali'
GROUP BY p.category, c.campaign_name;

-- Top 5 products ranked by IR%
SELECT product_name , category,
		ROUND((SUM(CASE
				WHEN promo_type = 'BOGOF' THEN base_price* `quantity_sold(after_promo)` *2
                WHEN promo_type = '500 Cashback' THEN (base_price-500)* `quantity_sold(after_promo)`
				WHEN promo_type = '50% OFF' THEN base_price* 0.5 * `quantity_sold(after_promo)`
                WHEN promo_type = '25%' THEN base_price * 0.75 * `quantity_sold(after_promo)`
				WHEN promo_type = '33%' THEN base_price* 0.67 * `quantity_sold(after_promo)`
				END
				  )- SUM(`quantity_sold(before_promo)` * base_price)) / SUM(`quantity_sold(before_promo)` * base_price) *100,2) AS 'IR%'
FROM fact_events
JOIN dim_products USING (product_code)
GROUP BY category , product_name
ORDER BY 'IR%' 	DESC
LIMIT 5;

-- Find average discount impact by promo type
SELECT promo_type,
	ROUND(
        ((SUM(`quantity_sold(after_promo)`) - SUM(`quantity_sold(before_promo)`)) 
        / SUM(`quantity_sold(before_promo)`) * 100),
        2
    ) AS 'ISU%'
FROM fact_events
GROUP BY promo_type
ORDER BY `ISU%` DESC;





    
		














