--DML-INSERT data
SET SERVEROUTPUT ON

BEGIN
  DELETE FROM alert_log; DELETE FROM interaction;
  DELETE FROM prescription_detail; DELETE FROM prescription;
  DELETE FROM medicine; DELETE FROM doctor; DELETE FROM patient;
  COMMIT;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

--  Insert fixed doctors
INSERT INTO doctor (full_name, specialization, contact_info) VALUES ('Dr. Eric Maniraguha', 'General', 'eric@auca.rw');
INSERT INTO doctor (full_name, specialization, contact_info) VALUES ('Dr. Jane Niyonzima', 'Internal Medicine', 'jane@hospital.rw');
INSERT INTO doctor (full_name, specialization, contact_info) VALUES ('Dr. Paul Habimana', 'Cardiology', 'paul@clinic.rw');

--  Insert fixed medicines (use several realistic ones)
INSERT INTO medicine (med_name, composition, category, dosage_form, strength, manufacturer)
VALUES ('Warfarin','warfarin sodium','Anticoagulant','Tablet','5 mg','MediLabs');
INSERT INTO medicine (med_name, composition, category, dosage_form, strength, manufacturer)
VALUES ('Ibuprofen','ibuprofen','Analgesic','Tablet','200 mg','PharmaCo');
INSERT INTO medicine (med_name, composition, category, dosage_form, strength, manufacturer)
VALUES ('Paracetamol','acetaminophen','Analgesic','Tablet','500 mg','GoodMeds');
INSERT INTO medicine (med_name, composition, category, dosage_form, strength, manufacturer)
VALUES ('Aspirin','acetylsalicylic acid','Analgesic','Tablet','75 mg','HealthCorp');
INSERT INTO medicine (med_name, composition, category, dosage_form, strength, manufacturer)
VALUES ('Amoxicillin','amoxicillin trihydrate','Antibiotic','Capsule','500 mg','BioPharm');
INSERT INTO medicine (med_name, composition, category, dosage_form, strength, manufacturer)
VALUES ('Simvastatin','simvastatin','Lipid-lowering','Tablet','20 mg','CardioMeds');
INSERT INTO medicine (med_name, composition, category, dosage_form, strength, manufacturer)
VALUES ('Metformin','metformin hydrochloride','Antidiabetic','Tablet','500 mg','GlucoHealth');

COMMIT;

--  Insert some interaction pairs (NOTE: canonical order med1_id < med2_id)
-- We'll compute med ids to be safe:
DECLARE
  v_w NUMBER; v_i NUMBER; v_p NUMBER; v_a NUMBER; v_am NUMBER; v_s NUMBER; v_m NUMBER;
BEGIN
  SELECT med_id INTO v_w FROM medicine WHERE med_name='Warfarin' AND rownum=1;
  SELECT med_id INTO v_i FROM medicine WHERE med_name='Ibuprofen' AND rownum=1;
  SELECT med_id INTO v_p FROM medicine WHERE med_name='Paracetamol' AND rownum=1;
  SELECT med_id INTO v_a FROM medicine WHERE med_name='Aspirin' AND rownum=1;
  SELECT med_id INTO v_am FROM medicine WHERE med_name='Amoxicillin' AND rownum=1;
  SELECT med_id INTO v_s FROM medicine WHERE med_name='Simvastatin' AND rownum=1;
  SELECT med_id INTO v_m FROM medicine WHERE med_name='Metformin' AND rownum=1;

  -- Warfarin + Ibuprofen -> Major
  IF v_w < v_i THEN
    INSERT INTO interaction (med1_id, med2_id, severity_level, effect_description, management_advice)
    VALUES (v_w, v_i, 'Major', 'Increased bleeding risk', 'Avoid combination; consult prescriber');
  ELSE
    INSERT INTO interaction (med1_id, med2_id, severity_level, effect_description, management_advice)
    VALUES (v_i, v_w, 'Major', 'Increased bleeding risk', 'Avoid combination; consult prescriber');
  END IF;

  -- Warfarin + Aspirin -> Major
  IF v_w < v_a THEN
    INSERT INTO interaction (med1_id, med2_id, severity_level, effect_description, management_advice)
    VALUES (v_w, v_a, 'Major', 'High bleeding risk with antiplatelet and anticoagulant', 'Avoid unless monitored');
  ELSE
    INSERT INTO interaction (med1_id, med2_id, severity_level, effect_description, management_advice)
    VALUES (v_a, v_w, 'Major', 'High bleeding risk with antiplatelet and anticoagulant', 'Avoid unless monitored');
  END IF;

  -- Simvastatin + Amoxicillin -> Moderate (example)
  IF v_s < v_am THEN
    INSERT INTO interaction (med1_id, med2_id, severity_level, effect_description, management_advice)
    VALUES (v_s, v_am, 'Moderate', 'Possible increased myopathy risk', 'Monitor muscle symptoms');
  ELSE
    INSERT INTO interaction (med1_id, med2_id, severity_level, effect_description, management_advice)
    VALUES (v_am, v_s, 'Moderate', 'Possible increased myopathy risk', 'Monitor muscle symptoms');
  END IF;

  -- Ibuprofen + Metformin -> Minor (example)
  IF v_i < v_m THEN
    INSERT INTO interaction (med1_id, med2_id, severity_level, effect_description, management_advice)
    VALUES (v_i, v_m, 'Minor', 'No major interaction but monitor GI effects', 'Monitor tolerance');
  ELSE
    INSERT INTO interaction (med1_id, med2_id, severity_level, effect_description, management_advice)
    VALUES (v_m, v_i, 'Minor', 'No major interaction but monitor GI effects', 'Monitor tolerance');
  END IF;

  COMMIT;
END;
/

--  Insert many patients (example: 100 patients)
DECLARE
  i NUMBER := 0;
BEGIN
  FOR i IN 1..100 LOOP
    INSERT INTO patient (full_name, date_of_birth, gender, contact_info)
    VALUES ('Patient ' || TO_CHAR(i), ADD_MONTHS(TRUNC(SYSDATE, 'YEAR'), - (18*12 + MOD(i, 600)) ), CASE WHEN MOD(i,2)=0 THEN 'F' ELSE 'M' END, 'patient' || i || '@example.com');
  END LOOP;
  COMMIT;
END;
/

--  Create 200 prescriptions and random prescription_details for testing
DECLARE
  v_min_patient NUMBER;
  v_max_patient NUMBER;
  v_min_med NUMBER;
  v_max_med NUMBER;
  v_min_doc NUMBER;
  v_max_doc NUMBER;
  v_pres_id NUMBER;
  i NUMBER;
  j NUMBER;
  v_pat NUMBER;
  v_doc NUMBER;
  v_med NUMBER;
BEGIN
  SELECT MIN(patient_id), MAX(patient_id) INTO v_min_patient, v_max_patient FROM patient;
  SELECT MIN(med_id), MAX(med_id) INTO v_min_med, v_max_med FROM medicine;
  SELECT MIN(doctor_id), MAX(doctor_id) INTO v_min_doc, v_max_doc FROM doctor;

  i := 0;
  FOR i IN 1..200 LOOP
    v_pat := TRUNC(DBMS_RANDOM.VALUE(v_min_patient, v_max_patient+1));
    v_doc := TRUNC(DBMS_RANDOM.VALUE(v_min_doc, v_max_doc+1));
    INSERT INTO prescription (patient_id, doctor_id, pres_date, remarks) VALUES (v_pat, v_doc, SYSDATE - TRUNC(DBMS_RANDOM.VALUE(0,30)), 'Auto-generated test prescription');
    -- get pres_id (use currval style or returning clause)
    SELECT pres_id INTO v_pres_id FROM (SELECT pres_id FROM prescription WHERE ROWNUM=1 ORDER BY pres_id DESC);

    -- add 1-4 medicines per prescription
    FOR j IN 1..TRUNC(DBMS_RANDOM.VALUE(1,4)) LOOP
      v_med := TRUNC(DBMS_RANDOM.VALUE(v_min_med, v_max_med+1));
      BEGIN
        INSERT INTO prescription_detail (pres_id, med_id, dose, frequency, duration_days)
        VALUES (v_pres_id, v_med, (TRUNC(DBMS_RANDOM.VALUE(1,2))||' tablet'), CASE WHEN MOD(j,2)=0 THEN 'once daily' ELSE 'twice daily' END, TRUNC(DBMS_RANDOM.VALUE(3,14)));
      EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        NULL; -- skip duplicate (pres_id, med_id) if unique enforced later
      END;
    END LOOP;
  END LOOP;
  COMMIT;
END;
/
--inserting sample data

INSERT INTO public_holidays VALUES (TO_DATE('2025-01-01','YYYY-MM-DD'), 'New Year');
INSERT INTO public_holidays VALUES (TO_DATE('2025-02-01','YYYY-MM-DD'), 'Heroes Day');
INSERT INTO public_holidays VALUES (TO_DATE('2025-07-01','YYYY-MM-DD'), 'Independence Day');

COMMIT;
-- ===== end sample_data.sql =====