WITH savings AS (
    SELECT owner_id, SUM(amount) AS total_savings, COUNT(*) AS savings_count
    FROM adashi_staging.savings_savingsaccount
    WHERE amount > 0
    GROUP BY owner_id
),
investments AS (
    SELECT owner_id, SUM(amount) AS total_investments, COUNT(*) AS investment_count
    FROM adashi_staging.plans_plan
    WHERE amount > 0 AND plan_type_id = 2
    GROUP BY owner_id
)

SELECT 
    u.id AS owner_id,
    u.name AS NAME,
    COALESCE(s.savings_count, 0) AS savings_count,
    COALESCE(i.investment_count, 0) AS investment_count,
    COALESCE(s.total_savings, 0) + COALESCE(i.total_investments, 0) AS total_deposits
FROM 
    adashi_staging.users_customuser u
    LEFT JOIN savings s ON u.id = s.owner_id
    LEFT JOIN investments i ON u.id = i.owner_id
WHERE 
    s.savings_count >= 1
    AND i.investment_count >= 1
ORDER BY 
    total_deposits DESC;
