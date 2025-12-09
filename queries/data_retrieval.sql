--data_retrieval.sql
-- Get all patients with prescriptions
SELECT p.full_name, pr.pres_id, pr.pres_date
FROM patient p
JOIN prescription pr ON p.patient_id = pr.patient_id;

-- List medicines in each prescription
SELECT pd.pres_id, m.med_name, pd.dose, pd.frequency
FROM prescription_detail pd
JOIN medicine m ON pd.med_id = m.med_id;

-- View all interactions
SELECT i.med1_id, i.med2_id, i.severity_level
FROM interaction i;

