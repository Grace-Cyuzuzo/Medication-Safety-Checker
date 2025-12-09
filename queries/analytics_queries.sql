--analytics_queries.sql
-- Count alerts by severity
SELECT severity_level, COUNT(*) AS alert_count
FROM alert_log
GROUP BY severity_level;

-- Most frequently interacting medicines
SELECT med1_id, med2_id, COUNT(*) AS occurrences
FROM alert_log
GROUP BY med1_id, med2_id
ORDER BY occurrences DESC;

-- Prescriptions with interactions
SELECT DISTINCT pres_id
FROM alert_log;

--BI queries
--Daily Alerts--
SELECT 
    TRUNC(alert_date) AS day,
    COUNT(*) AS total_alerts
FROM alert_log
GROUP BY TRUNC(alert_date)
ORDER BY day;

--Severity Trend by Month--
SELECT 
    TO_CHAR(alert_date, 'YYYY-MM') AS month,
    severity_level,
    COUNT(*) AS total
FROM alert_log
GROUP BY TO_CHAR(alert_date, 'YYYY-MM'), severity_level
ORDER BY month, severity_level;

--Most risky medicine category--
SELECT 
    m.category,
    COUNT(*) AS total_interactions
FROM alert_log a
JOIN medicine m ON a.med1_id = m.med_id
GROUP BY m.category
ORDER BY total_interactions DESC;

---
