
--procedures--
CREATE OR REPLACE PROCEDURE check_prescription(
    p_pres_id IN NUMBER
)
IS
    CURSOR c_meds IS
        SELECT med_id FROM prescription_detail
        WHERE pres_id = p_pres_id;

    TYPE t_med_list IS TABLE OF NUMBER;
    v_meds t_med_list := t_med_list();
    v_severity VARCHAR2(20);
    v_patient NUMBER;
    v_doc NUMBER;
BEGIN
    -- Get prescription header info
    SELECT patient_id, doctor_id INTO v_patient, v_doc
    FROM prescription
    WHERE pres_id = p_pres_id;

    -- Load meds into collection
    FOR r IN c_meds LOOP
        v_meds.EXTEND;
        v_meds(v_meds.COUNT) := r.med_id;
    END LOOP;

    -- Pairwise check (i < j)
    FOR i IN 1 .. v_meds.COUNT - 1 LOOP
        FOR j IN i+1 .. v_meds.COUNT LOOP
            v_severity := check_interaction(v_meds(i), v_meds(j));

            IF v_severity <> 'NONE' AND v_severity <> 'ERROR' THEN
                INSERT INTO alert_log(patient_id, pres_id, med1_id, med2_id, severity_level, message, handled_by)
                VALUES (
                    v_patient,
                    p_pres_id,
                    LEAST(v_meds(i), v_meds(j)),
                    GREATEST(v_meds(i), v_meds(j)),
                    v_severity,
                    'Interaction detected during manual check',
                    v_doc
                );
            END IF;
        END LOOP;
    END LOOP;

    COMMIT;

END;
/
CREATE OR REPLACE PROCEDURE add_prescription_with_details(
    p_patient_id IN NUMBER,
    p_doctor_id  IN NUMBER,
    p_remarks    IN VARCHAR2,
    p_med_list   IN SYS.ODCINUMBERLIST  -- input list of med IDs
)
IS
    v_pres_id NUMBER;
BEGIN
    INSERT INTO prescription(patient_id, doctor_id, remarks)
    VALUES(p_patient_id, p_doctor_id, p_remarks)
    RETURNING pres_id INTO v_pres_id;

    FOR i IN 1 .. p_med_list.COUNT LOOP
        INSERT INTO prescription_detail(pres_id, med_id, dose, frequency, duration_days)
        VALUES (v_pres_id, p_med_list(i), '1 tablet', 'daily', 5);
    END LOOP;

    -- Call checker
    check_prescription(v_pres_id);

    COMMIT;
END;
/

--procedure that simulates trigger for testing the restriction rule
CREATE OR REPLACE PROCEDURE test_date_restriction(p_date IN DATE) IS
    v_day VARCHAR2(3);
    v_is_holiday NUMBER;
BEGIN
    v_day := TO_CHAR(p_date, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN');

    DBMS_OUTPUT.PUT_LINE('Testing date: ' || TO_CHAR(p_date, 'DAY'));

    IF v_day IN ('MON','TUE','WED','THU','FRI') THEN
        DBMS_OUTPUT.PUT_LINE('DENIED: Weekday restriction (Mon–Fri).');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Allowed: Weekend.');
    END IF;

    SELECT COUNT(*)
    INTO v_is_holiday
    FROM public_holidays
    WHERE holiday_date = p_date;

    IF v_is_holiday > 0 THEN
        DBMS_OUTPUT.PUT_LINE('DENIED: Today is a Public Holiday.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Allowed: Not a holiday.');
    END IF;
END;
/
--end procedures.sql--