WITH TransactionStats AS (
    SELECT 
        s.owner_id,
        COUNT(s.id) AS total_transactions,
        GREATEST(
            DATEDIFF(
                COALESCE(MAX(s.transaction_date), CURRENT_DATE),
                COALESCE(MIN(s.transaction_date), CURRENT_DATE)
            ) / 30.0, 
            1
        ) AS months_active
    FROM 
        adashi_staging.savings_savingsaccount s
    WHERE 
        s.transaction_date IS NOT NULL
    GROUP BY 
        s.owner_id
),
FrequencyCalc AS (
    SELECT 
        owner_id,
        total_transactions / months_active AS avg_transactions_per_month
    FROM 
        TransactionStats
),
FrequencyCategories AS (
    SELECT 
        owner_id,
        avg_transactions_per_month,
        CASE 
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM 
        FrequencyCalc
)
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM 
    FrequencyCategories
GROUP BY 
    frequency_category
ORDER BY 
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'Low Frequency' THEN 3
    END;
