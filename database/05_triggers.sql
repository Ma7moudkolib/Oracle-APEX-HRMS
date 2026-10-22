-- Trigger definitions extracted from the supplied DDL export.

-- TRG_ATTENDANCE_STATUS
CREATE OR REPLACE TRIGGER "TRG_ATTENDANCE_STATUS" 
BEFORE INSERT OR UPDATE OF check_in
ON attendance
FOR EACH ROW
BEGIN
    IF :NEW.check_in IS NOT NULL THEN
        IF :NEW.check_in >
           TRUNC(:NEW.check_in) + (10 / 24)
        THEN
            :NEW.status := 'LATE';
        ELSE
            :NEW.status := 'PRESENT';
        END IF;
    END IF;
END;
/

-- TRG_USERS_BI
CREATE OR REPLACE TRIGGER "TRG_USERS_BI" 
BEFORE INSERT ON USERS
FOR EACH ROW
BEGIN
    :NEW.USERNAME := UPPER(TRIM(:NEW.USERNAME));
    :NEW.EMAIL := LOWER(TRIM(:NEW.EMAIL));

    :NEW.PASSWORD := HASH_PASSWORD(:NEW.PASSWORD);
    :NEW.IS_ACTIVE := 'N';
END;
/
