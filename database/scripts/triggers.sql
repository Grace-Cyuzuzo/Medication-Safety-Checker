--trigger.sql--
CREATE OR REPLACE TRIGGER ctr_prescription_interaction
FOR INSERT OR UPDATE ON prescription_detail
COMPOUND TRIGGER

    TYPE t_med_list IS TABLE OF NUMBER;
    meds t_med_list;
    v_pres_id NUMBER;
    v_patient NUMBER;
    v_doc NUMBER;

    

    BEFORE EACH ROW IS
    BEGIN
        NULL;  -- needed only to keep structure valid
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        NULL;  -- also required to keep proper structure
    END AFTER EACH ROW;

    
    AFTER STATEMENT IS
    BEGIN
        -- Get prescription ID of last affected row
        SELECT pres_id
        INTO v_pres_id
        FROM prescription_detail
        WHERE ROWID = (SELECT MAX(ROWID) FROM prescription_detail);

        -- Load all medicines for this prescription
        SELECT med_id BULK COLLECT INTO meds
        FROM prescription_detail
        WHERE pres_id = v_pres_id;

        -- Get patient and doctor
        SELECT patient_id, doctor_id
        INTO v_patient, v_doc
        FROM prescription
        WHERE pres_id = v_pres_id;

        -- Pairwise comparison
        FOR i IN 1 .. meds.COUNT - 1 LOOP
            FOR j IN i + 1 .. meds.COUNT LOOP

                DECLARE
                    v_sev VARCHAR2(20);
                    m1 NUMBER := LEAST(meds(i), meds(j));
                    m2 NUMBER := GREATEST(meds(i), meds(j));
                BEGIN
                    SELECT severity_level
                    INTO v_sev
                    FROM interaction
                    WHERE med1_id = m1
                    AND med2_id = m2;

                    INSERT INTO alert_log
                    (patient_id, pres_id, med1_id, med2_id, severity_level, message, handled_by)
                    VALUES
                    (v_patient, v_pres_id, m1, m2, v_sev,
                     'Trigger detected interaction', v_doc);

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN NULL;
                END;

            END LOOP;
        END LOOP;

    END AFTER STATEMENT;

END ctr_prescription_interaction;
/


--audit logging triger

CREATE OR REPLACE TRIGGER trg_prescription_detail_audit
AFTER UPDATE OF med_id ON prescription_detail
FOR EACH ROW
BEGIN
    INSERT INTO prescription_detail_audit
        (detail_id, old_med_id, new_med_id, changed_by, action_type)
    VALUES
        (:OLD.detail_id, :OLD.med_id, :NEW.med_id, USER, 'UPDATE');
END;
/

--restriction rule triggers
--on patients
CREATE OR REPLACE TRIGGER trg_patient_restrict
BEFORE INSERT OR UPDATE OR DELETE ON patient
DECLARE
    v_day VARCHAR2(3);
    v_is_holiday NUMBER;
BEGIN
    -- weekday restriction
    v_day := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN');

    IF v_day IN ('MON','TUE','WED','THU','FRI') THEN
        RAISE_APPLICATION_ERROR(-20000,
            'DENIED: Weekday restriction (Mon–Fri).');
    END IF;

    -- public holiday restriction
    SELECT COUNT(*)
    INTO v_is_holiday
    FROM public_holidays
    WHERE holiday_date = TRUNC(SYSDATE)
      AND holiday_date BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE)+30;

    IF v_is_holiday > 0 THEN
        RAISE_APPLICATION_ERROR(-20999,
            'DENIED: Today is a Public Holiday.');
    END IF;
END;
/
--on doctors
CREATE OR REPLACE TRIGGER trg_doctor_restrict
BEFORE INSERT OR UPDATE OR DELETE ON doctor
DECLARE
    v_day VARCHAR2(3);
    v_is_holiday NUMBER;
BEGIN
    -- weekday restriction
    v_day := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN');

    IF v_day IN ('MON','TUE','WED','THU','FRI') THEN
        RAISE_APPLICATION_ERROR(-20000,
            'DENIED: Weekday restriction (Mon–Fri).');
    END IF;

    -- public holiday restriction
    SELECT COUNT(*)
    INTO v_is_holiday
    FROM public_holidays
    WHERE holiday_date = TRUNC(SYSDATE)
      AND holiday_date BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE)+30;

    IF v_is_holiday > 0 THEN
        RAISE_APPLICATION_ERROR(-20999,
            'DENIED: Today is a Public Holiday.');
    END IF;
END;
/

--on medicine

CREATE OR REPLACE TRIGGER trg_medicine_restrict
BEFORE INSERT OR UPDATE OR DELETE ON medicine
DECLARE
    v_day VARCHAR2(3);
    v_is_holiday NUMBER;
BEGIN
    -- weekday restriction
    v_day := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN');

    IF v_day IN ('MON','TUE','WED','THU','FRI') THEN
        RAISE_APPLICATION_ERROR(-20000,
            'DENIED: Weekday restriction (Mon–Fri).');
    END IF;

    -- public holiday restriction
    SELECT COUNT(*)
    INTO v_is_holiday
    FROM public_holidays
    WHERE holiday_date = TRUNC(SYSDATE)
      AND holiday_date BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE)+30;

    IF v_is_holiday > 0 THEN
        RAISE_APPLICATION_ERROR(-20999,
            'DENIED: Today is a Public Holiday.');
    END IF;
END;


