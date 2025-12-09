--audit_queries.sql
-- View audit changes in prescription_detail
SELECT *
FROM prescription_detail_audit
ORDER BY changed_on DESC;

-- Count number of edits per user
SELECT changed_by, COUNT(*) AS change_count
FROM prescription_detail_audit
GROUP BY changed_by;
