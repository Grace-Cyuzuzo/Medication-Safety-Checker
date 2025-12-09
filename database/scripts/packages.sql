--packages.sql--

CREATE OR REPLACE PACKAGE med_checker_pkg AS
    FUNCTION check_interaction(p_med1_id NUMBER, p_med2_id NUMBER)
        RETURN VARCHAR2;

    PROCEDURE check_prescription(p_pres_id NUMBER);

    PROCEDURE add_prescription_with_details(
        p_patient_id NUMBER,
        p_doctor_id NUMBER,
        p_remarks VARCHAR2,
        p_med_list SYS.ODCINUMBERLIST
    );
END med_checker_pkg;
/

CREATE OR REPLACE PACKAGE BODY med_checker_pkg AS

    -- function
    FUNCTION check_interaction(p_med1_id NUMBER, p_med2_id NUMBER)
        RETURN VARCHAR2 IS
        v_med1 NUMBER;
        v_med2 NUMBER;
        v_severity VARCHAR2(20);
    BEGIN
        v_med1 := LEAST(p_med1_id, p_med2_id);
        v_med2 := GREATEST(p_med1_id, p_med2_id);

        SELECT severity_level INTO v_severity
        FROM interaction
        WHERE med1_id = v_med1
          AND med2_id = v_med2;

        RETURN v_severity;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN 'NONE';
    END;

    -- procedure: check_prescription
    PROCEDURE check_prescription(p_pres_id NUMBER) IS
        CURSOR c_meds IS SELECT med_id FROM prescription_detail WHERE pres_id = p_pres_id;
        TYPE t_list IS TABLE OF NUMBER;
        v_list t_list := t_list();
        v_patient NUMBER; v_doc NUMBER;
        v_sev VARCHAR2(20);
    BEGIN
        SELECT patient_id, doctor_id INTO v_patient, v_doc
        FROM prescription WHERE pres_id = p_pres_id;

        FOR r IN c_meds LOOP
            v_list.EXTEND; v_list(v_list.COUNT) := r.med_id;
        END LOOP;

        FOR i IN 1 .. v_list.COUNT-1 LOOP
            FOR j IN i+1 .. v_list.COUNT LOOP
                v_sev := check_interaction(v_list(i), v_list(j));
                IF v_sev <> 'NONE' THEN
                    INSERT INTO alert_log(patient_id, pres_id, med1_id, med2_id, severity_level, message, handled_by)
                    VALUES(v_patient, p_pres_id, LEAST(v_list(i),v_list(j)), GREATEST(v_list(i),v_list(j)), v_sev, 'Auto alert', v_doc);
                END IF;
            END LOOP;
        END LOOP;

        COMMIT;
    END;

    -- procedure: add_prescription_with_details
    PROCEDURE add_prescription_with_details(
        p_patient_id NUMBER,
        p_doctor_id NUMBER,
        p_remarks VARCHAR2,
        p_med_list SYS.ODCINUMBERLIST
    ) IS
        v_pres NUMBER;
    BEGIN
        INSERT INTO prescription(patient_id, doctor_id, remarks)
        VALUES(p_patient_id, p_doctor_id, p_remarks)
        RETURNING pres_id INTO v_pres;

        FOR i IN 1 .. p_med_list.COUNT LOOP
            INSERT INTO prescription_detail(pres_id, med_id, dose, frequency, duration_days)
            VALUES(v_pres, p_med_list(i), '1 tablet', 'daily', 7);
        END LOOP;

        check_prescription(v_pres);
        COMMIT;
    END;

END med_checker_pkg;
/
--end packages.sql--