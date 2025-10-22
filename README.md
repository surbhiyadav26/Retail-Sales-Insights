# FMCG Sales & Promotion Analysis Dashboard  

A data analytics project focused on understanding **promotion effectiveness** and **revenue impact** in the FMCG domain.  
This project combines **MySQL** for data preparation and **Power BI** for visualization and insights.

---

##  Dashboard Overview  

**🔗 Power BI Dashboard:** [View Dashboard Here](https://app.powerbi.com/view?r=eyJrIjoiOGM5ZGM1MTUtNjk1Zi00NzNlLTk1YjQtMGI0ZDFkOTFhNTVhIiwidCI6ImQ1MTFhNzlhLTI4MzgtNDlmZS04MDJjLWVhYjhjNzk4NjBjZSJ9
)

The dashboard highlights:
- 📈 Incremental revenue before vs. after promotions  
- 🏆 Top performing campaigns and stores  
- 🛍️ Promotion type effectiveness (BOGOF, Cashback, Discounts)  
- 🏙️ Regional and category-wise performance  
- 🔍 Insights on high-growth cities and product categories  

---

## 🧠 Key Insights  

- **Diwali** generated the highest total revenue, while **Sankranti** showed stronger growth %.  
- Top performing cities: **Bengaluru, Chennai, and Hyderabad**.  
- Emerging markets: **Mangalore, Vijayawada, Trivandrum, and Madurai**.  
- **BOGOF** and **Cashback** offers outperformed percentage discounts.  
- **Grocery & Staples (Combo1)** had major sales uplift — strong preference for bundled deals.  
- **Home Appliances** performed well, while **Personal Care** lagged in incremental revenue.  

---

## 🧩 Tools & Technologies  

| Tool | Purpose |
|------|----------|
| **MySQL** | Data cleaning, transformation, and KPI calculations |
| **Power BI** | Data modeling and visualization |
| **Excel** | Source data exploration and validation |

---

## 💾 SQL Queries  

Below are a few key queries used for data analysis:

### 🔹 1. Total Revenue Before & After Promotions
```sql
SELECT campaign_name,
       ROUND(SUM(base_price * `quantity_sold(before_promo)`) / 1000000, 2) AS total_revenue_before_promo,
       ROUND(SUM(CASE
                   WHEN promo_type = 'BOGOF' THEN base_price * 0.5 * (`quantity_sold(after_promo)` * 2)
                   WHEN promo_type = '500 Cashback' THEN (base_price - 500) * `quantity_sold(after_promo)`
                   WHEN promo_type = '50% OFF' THEN base_price * 0.5 * `quantity_sold(after_promo)`
                   WHEN promo_type = '33% OFF' THEN base_price * 0.67 * `quantity_sold(after_promo)`
                   WHEN promo_type = '25% OFF' THEN base_price * 0.75 * `quantity_sold(after_promo)`
                 END) / 1000000, 2) AS total_revenue_after_promo
FROM fact_events
JOIN dim_campaigns USING (campaign_id)
GROUP BY campaign_name;
```
### 🔹 2. ISU% of Categories During Diwali
```sql
SELECT 
    p.category, 
    c.campaign_name,
    ROUND(
        ((SUM(`quantity_sold(after_promo)`) - SUM(`quantity_sold(before_promo)`)) 
        / SUM(`quantity_sold(before_promo)`) * 100),2
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
```
### 🔹 3. Top % products ranked by IR%
```sql
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
GROUP BY category, product_name
ORDER BY 'IR%' 	DESC
LIMIT 5;
```

