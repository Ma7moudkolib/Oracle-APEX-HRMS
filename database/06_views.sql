-- View definitions extracted from the supplied DDL export.

-- VW_PAYROLL_RUNS
CREATE OR REPLACE VIEW "VW_PAYROLL_RUNS" ("PAYROLL_RUN_ID", "PAYROLL_MONTH", "CREATED_BY", "CREATED_AT", "STATUS", "APPROVED_BY", "APPROVED_AT", "TOTAL_EMPLOYEES", "TOTAL_NET_AMOUNT", "TOTAL_ABSENT_DAYS", "TOTAL_LATE_DAYS", "TOTAL_DEDUCTIONS") AS 
  SELECT
    pr.payroll_run_id,
    pr.payroll_month,
    creator.first_name || ' ' || creator.last_name AS created_by,
    pr.created_at,
    pr.status,
    approver.first_name || ' ' || approver.last_name AS approved_by,
    pr.approved_at,

    COUNT(p.payroll_id) AS total_employees,

    NVL(SUM(p.net_salary), 0) AS total_net_amount,

    NVL(SUM(
        NVL(a.absent_days, 0)
    ), 0) AS total_absent_days,

    NVL(SUM(
        NVL(a.late_days, 0)
    ), 0) AS total_late_days,

    NVL(SUM(p.deductions), 0) AS total_deductions

FROM payroll_runs pr

JOIN employees creator
    ON creator.employee_id = pr.created_by

LEFT JOIN employees approver
    ON approver.employee_id = pr.approved_by

LEFT JOIN payroll p
    ON p.payroll_run_id = pr.payroll_run_id

LEFT JOIN (
    SELECT
        employee_id,
        TRUNC(attendance_date, 'MM') AS attendance_month,
        SUM(CASE WHEN status = 'ABSENT' THEN 1 ELSE 0 END) AS absent_days,
        SUM(CASE WHEN status = 'LATE' THEN 1 ELSE 0 END) AS late_days
    FROM attendance
    GROUP BY employee_id, TRUNC(attendance_date, 'MM')
) a
    ON a.employee_id = p.employee_id
   AND a.attendance_month = TRUNC(pr.payroll_month, 'MM')

GROUP BY
    pr.payroll_run_id,
    pr.payroll_month,
    creator.first_name,
    creator.last_name,
    pr.created_at,
    pr.status,
    approver.first_name,
    approver.last_name,
    pr.approved_at;

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
