-- ==========================================
-- -- Table: bronze.crm_cust_info
-- ==========================================

-- Preview raw data
SELECT
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
FROM bronze.crm_cust_info;

-- Duplicate Check
SELECT cst_id, COUNT(*) AS duplicate
FROM silver.crm_cust_info
GROUP BY
    cst_id
HAVING
    COUNT(*) > 1
    OR cst_id IS NULL

-- Flaging and Ranking the cst_id based on the ceartion Date
SELECT *, ROW_NUMBER() OVER (
        PARTITION BY
            cst_id
        ORDER BY cst_create_date DESC
    ) as falg_last
FROM bronze.crm_cust_info

-- Duble Check the NULLs and the Dublicate value
SELECT *
FROM (
        SELECT *, ROW_NUMBER() OVER (
                PARTITION BY
                    cst_id
                ORDER BY cst_create_date DESC
            ) as flag_last
        FROM bronze.crm_cust_info
    ) t
WHERE
    flag_last = 1

-- Checking the useless spaces
-- Expectatioan: No Result
SELECT cst_ tname
FROM bronze.crm_cust_info
WHERE
    cst_firstname != TRIM(cst_firstname)

-- Data Standardization & Consistency for the gender cloumn
SELECT DISTINCT cst_gndr FROM bronze.crm_cust_info

-- Data Standardization & Consistency for the marital status cloumn
SELECT DISTINCT cst_marital_status FROM bronze.crm_cust_info

-- Final Result
SELECT * FROM silver.crm_cust_info

-- ==========================================
-- -- Table: bronze.crm_prd_info
-- ==========================================

-- Preview raw data
SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;

-- Duplicate Check
SELECT prd_id, COUNT(*) AS duplicate
FROM bronze.crm_prd_info
GROUP BY
    prd_id
HAVING
    COUNT(*) > 1
    OR prd_id IS NULL

-- Check the category id against the erp category table
SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2

-- Check the product key against the sales details table
SELECT sls_prd_key FROM bronze.crm_sales_details

-- Checking the useless spaces
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE
    prd_nm != TRIM(prd_nm)

-- Checking for Nulls or negative values in cost
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE
    prd_cost < 0
    OR prd_cost IS NULL

-- Data Standardization & Consistency for the product line cloumn
SELECT DISTINCT prd_line FROM bronze.crm_prd_info

-- Check for invalid date order
SELECT * FROM bronze.crm_prd_info WHERE prd_end_dt < prd_start_dt

-- Date and time issue
SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_start_dt,
    prd_end_dt,
    LEAD(prd_start_dt) OVER (
        PARTITION BY
            prd_key
        ORDER BY prd_start_dt
    ) -1 AS prd_start_dt_test
FROM bronze.crm_prd_info
WHERE
    prd_key IN (
        'AC-HE-HL-U509-R',
        'AC-HE-HL-U509'
    )

-- Final Result
SELECT * FROM silver.crm_prd_info

-- ==========================================
-- -- Table: bronze.crm_sales_details
-- ==========================================

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details;

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details sls_prd_key NOT IN (
        SELECT prd_key
        FROM silver.crm_prd_info
    );

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details sls_cust_id NOT IN (
        SELECT cst_id
        FROM silver.crm_cust_info
    );

SELECT NULLIF(sls_order_dt, 0)
FROM bronze.crm_sales_details
WHERE
    sls_order_dt <= 0
    OR LEN(sls_order_dt) != 8
    OR sls_order_dt > 20500101
    OR sls_order_dt < 19000101

SELECT NULLIF(sls_ship_dt, 0)
FROM bronze.crm_sales_details
WHERE
    sls_ship_dt <= 0
    OR LEN(sls_ship_dt) != 8
    OR sls_ship_dt > 20500101
    OR sls_ship_dt < 19000101

SELECT NULLIF(sls_due_dt, 0)
FROM bronze.crm_sales_details
WHERE
    sls_due_dt <= 0
    OR LEN(sls_due_dt) != 8
    OR sls_due_dt > 20500101
    OR sls_due_dt < 19000101

SELECT *
FROM bronze.crm_sales_details
WHERE
    sls_order_dt > sls_ship_dt
    OR sls_order_dt > sls_due_dt

SELECT DISTINCT
    sls_sales AS old_sls_sales,
    sls_quantity,
    sls_price AS old_sls_price,
    CASE
        WHEN sls_sales IS NULL
        OR sls_sales <= 0
        OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    CASE
        WHEN sls_price IS NULL
        OR sls_price <= 0 THEN sls_price / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details
WHERE
    sls_sales != sls_quantity * sls_price
    OR sls_sales IS NULL
    OR sls_quantity IS NULL
    OR sls_price IS NULL
    OR sls_sales <= 0
    OR sls_quantity <= 0
    OR sls_price <= 0
ORDER BY
    sls_sales,
    sls_quantity,
    sls_price;

SELECT * FROM silver.crm_sales_details

-- ==========================================
-- -- Table: bronze.erp_cust_az12
-- ==========================================
SELECT cid, bdate, gen FROM bronze.erp_cust_az12;

SELECT cid, bdate, gen
FROM bronze.erp_cust_az12
WHERE
    cid LIKE '%AW00011000%'

SELECT DISTINCT
    bdate
FROM bronze.erp_cust_az12
WHERE
    bdate < '1924-01-01'
    OR bdate > GETDATE()

SELECT cid, bdate, gen FROM silver.erp_cust_az12;

-- ==========================================
-- -- Table: bronze.erp_loc_a101
-- ==========================================
SELECT cid, cntry FROM bronze.erp_loc_a101;

SELECT cst_key FROM silver.crm_cust_info

-- ==========================================
-- -- Table: bronze.erp_px_cat_g1v2
-- ==========================================

SELECT id, cat, subcat, maintenance FROM bronze.erp_px_cat_g1v2;

SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE
    cat != TRIM(cat)
    OR subcat != TRIM(subcat)
    OR maintenance != TRIM(maintenance)

SELECT DISTINCT * FROM bronze.erp_px_cat_g1v2

SELECT  * FROM silver.erp_px_cat_g1v2

