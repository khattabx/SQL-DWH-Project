-- ======================================
-- Test Dimension: gold.dim_customers
-- ======================================

SELECT DISTINCT
    ci.cst_gndr,
    ca.gen,
    CASE
        WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'N/A')
    END AS new_gen
FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid
ORDER BY 1, 2

SELECT * FROM gold.dim_customers

SELECT customer_key, COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY
    customer_key
HAVING
    COUNT(*) > 1;

-- ======================================
-- Test Dimension: gold.crm_prd_info
-- ======================================

SELECT pn.prd_id, pn.prd_key, pn.prd_nm, pn.cat_id, pc.cat, pc.subcat, pc.maintenance, pn.prd_cost, pn.prd_line, pn.prd_start_dt
FROM silver.crm_prd_info pn
    LEFT JOIN silver.erp_px_cat_g1v2 pc ON pn.cat_id = pc.id
WHERE
    prd_end_dt IS NULL

SELECT product_key, COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY
    product_key
HAVING
    COUNT(*) > 1;

-- ======================================
-- Test Dimension: gold.fact_sales
-- ======================================

SELECT *
FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
    LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
WHERE
    p.product_key IS NULL
    OR c.customer_key IS NULL