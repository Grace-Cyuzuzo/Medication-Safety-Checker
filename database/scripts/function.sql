--function
CREATE OR REPLACE FUNCTION check_interaction(
    p_med1_id IN NUMBER,
    p_med2_id IN NUMBER
) RETURN VARCHAR2
IS
    v_med1 NUMBER;
    v_med2 NUMBER;
    v_severity interaction.severity_level%TYPE;
BEGIN
    -- ensure med1 < med2 (canonical order)
    v_med1 := LEAST(p_med1_id, p_med2_id);
    v_med2 := GREATEST(p_med1_id, p_med2_id);

    SELECT severity_level
    INTO v_severity
    FROM interaction
    WHERE med1_id = v_med1
      AND med2_id = v_med2;

    RETURN v_severity;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'NONE';
    WHEN OTHERS THEN
        RETURN 'ERROR';
END;
/
--END function.sql 