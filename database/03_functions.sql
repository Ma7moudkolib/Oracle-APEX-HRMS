-- Function definitions extracted from the supplied DDL export.

-- HASH_PASSWORD
create or replace FUNCTION HASH_PASSWORD (
    P_PASSWORD IN VARCHAR2
)
RETURN VARCHAR2
IS
    L_HASH VARCHAR2(64);
BEGIN
    IF P_PASSWORD IS NULL THEN
        RETURN NULL;
    END IF;

    EXECUTE IMMEDIATE
        'SELECT LOWER(STANDARD_HASH(:p_password, ''SHA256'')) FROM dual'
        INTO L_HASH
        USING P_PASSWORD;

    RETURN L_HASH;
END HASH_PASSWORD;
/

-- IS_WORKING_DAY
create or replace FUNCTION is_working_day (
    p_date IN DATE
)
RETURN NUMBER
IS
    l_count NUMBER;
    l_day   VARCHAR2(3);
BEGIN
    IF p_date IS NULL THEN
        RETURN 0;
    END IF;

    -- Get the day name independently of session language
    l_day := TO_CHAR(p_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');

    -- Friday and Saturday are weekly off days
    IF l_day IN ('FRI', 'SAT') THEN
        RETURN 0;
    END IF;

    -- Check official holidays
    SELECT COUNT(*)
    INTO l_count
    FROM holidays
    WHERE holiday_date = TRUNC(p_date);

    IF l_count > 0 THEN
        RETURN 0;
    END IF;

    RETURN 1;
END;
/

-- GET_APPROVED_LEAVE_TYPE
create or replace FUNCTION get_approved_leave_type (
    p_employee_id IN NUMBER,
    p_date        IN DATE
)
RETURN VARCHAR2
IS
    l_leave_type_name leave_types.leave_type_name%TYPE;
BEGIN
    SELECT lt.leave_type_name
    INTO l_leave_type_name
    FROM leave_requests lr
    JOIN leave_types lt
        ON lt.leave_type_id = lr.leave_type_id
    WHERE lr.employee_id = p_employee_id
      AND TRUNC(p_date) BETWEEN TRUNC(lr.start_date)
                            AND TRUNC(lr.end_date)
      AND lr.status = 'APPROVED'
      AND ROWNUM = 1;

    RETURN l_leave_type_name;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/

-- DETERMINE_ATTENDANCE_STATUS
create or replace FUNCTION determine_attendance_status (
    p_employee_id IN NUMBER,
    p_date        IN DATE,
    p_check_in    IN DATE
)
RETURN VARCHAR2
IS
    l_leave_type VARCHAR2(50);
    l_is_paid    leave_types.is_paid%TYPE;
BEGIN
    IF is_working_day(p_date) = 0 THEN
        RETURN 'DAY_OFF';
    END IF;

    l_leave_type := get_approved_leave_type(
        p_employee_id,
        p_date
    );

    IF l_leave_type IS NOT NULL THEN
        SELECT is_paid
        INTO l_is_paid
        FROM leave_types
        WHERE leave_type_name = l_leave_type;

        IF l_is_paid = 'Y' THEN
            RETURN 'PAID_LEAVE';
        ELSE
            RETURN 'ABSENT';
        END IF;
    END IF;

    IF p_check_in IS NULL THEN
        RETURN 'ABSENT';
    END IF;

    IF p_check_in > TRUNC(p_date) + (10 / 24) THEN
        RETURN 'LATE';
    END IF;

    RETURN 'PRESENT';
END;
/

-- LOGIN_USER
create or replace FUNCTION LOGIN_USER (
    P_USERNAME IN VARCHAR2,
    P_PASSWORD IN VARCHAR2
)
RETURN BOOLEAN
IS
    L_STORED_PASSWORD USERS.PASSWORD%TYPE;
    L_IS_ACTIVE       USERS.IS_ACTIVE%TYPE;
BEGIN
    SELECT PASSWORD, IS_ACTIVE
      INTO L_STORED_PASSWORD, L_IS_ACTIVE
      FROM USERS
     WHERE UPPER(USERNAME) = UPPER(TRIM(P_USERNAME))
        OR LOWER(EMAIL) = LOWER(TRIM(P_USERNAME));

    IF L_IS_ACTIVE <> 'Y' THEN
        RETURN FALSE;
    END IF;

    RETURN L_STORED_PASSWORD = HASH_PASSWORD(P_PASSWORD);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN TOO_MANY_ROWS THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        RETURN FALSE;
END LOGIN_USER;
/

-- HRMS_LOGIN_USER
create or replace FUNCTION HRMS_LOGIN_USER  (
    P_USERNAME IN VARCHAR2,
    P_PASSWORD IN VARCHAR2
)
RETURN BOOLEAN
IS
    L_STORED_PASSWORD USERS.PASSWORD%TYPE;
    L_IS_ACTIVE       USERS.IS_ACTIVE%TYPE;
BEGIN
    SELECT PASSWORD, IS_ACTIVE
      INTO L_STORED_PASSWORD, L_IS_ACTIVE
      FROM USERS
     WHERE UPPER(USERNAME) = UPPER(TRIM(P_USERNAME))
        OR LOWER(EMAIL) = LOWER(TRIM(P_USERNAME));

    IF L_IS_ACTIVE <> 'Y' THEN
        RETURN FALSE;
    END IF;

    RETURN L_STORED_PASSWORD = HASH_PASSWORD(P_PASSWORD);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN TOO_MANY_ROWS THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        RETURN FALSE;
END HRMS_LOGIN_USER;
/
